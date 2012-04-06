require 'RMagick'
include Magick

class Day < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  belongs_to :week
  has_many :shifts, dependent: :destroy

  accepts_nested_attributes_for :shifts, allow_destroy: true

  attr_accessible :shifts_attributes

  validates_associated :shifts
  validates_presence_of :date
  # validates_presence_of :week  --  causes problems!

  def shift_attributes=( attrs ) # invoked on an update (that is, on submitting an update form)
    # assert existance
    self.shifts.update(attrs.keys, attrs.values)
    #self.create_status_image is invoked on a shift update
  end

  def status_image_name
    str = self.shifts_sorted_for_status_image.collect{ |shift|
      (shift.free? and shift.active?) ?
        (shift.enabled ?
          shift.saison.name.chars.first.upcase :
          shift.saison.name.chars.first.downcase
        ) :
        '0'
    }.join
    "day_status_#{str}.png"
  end

  # Heroku has a read-only file system, hence we created all status images upfront.
  def create_status_image
    img_path = Rails.root + "app/assets/images/" + self.status_image_name
    self.create_status_image_stacked.write(img_path) unless File.exists?(img_path)
  end

  def date_str fmt = '%A %d.%m.%Y'
    return self.date.strftime( fmt )
    # TODO: do better localization of weekday names
  end
  def key_for_cache
    self.date.strftime( '%Y%m%d' )
  end

  # intended use: my_day.plus  1.day
  # or            my_day.minus 1.week
  def plus( time )
    Day.find_by_date( self.date + time )
  end
  def minus( time )
    Day.find_by_date( self.date - time )
  end

  def active?
    !self.date.past? and
    Saison.all.any?{ |saison| self.date.between? saison.begin, saison.end }
  end
  def enabled?( saison )
    saison_shifts = self.shifts.group_by(&:saison)[saison]
    saison_shifts && saison_shifts.any?(&:enabled?)
  end

  def find_shifts_by_saison( saison )
    # Note: self.shifts.find_by_saison  is not possible, since the saison attibute is a delegate to the shiftinfo
    # (Even when Shift declares "has_one :saison, through: :shiftinfo", ActiveRecord can still not query by saison.)
    self.shifts.all(include: :shiftinfo).select { |shift| shift.shiftinfo.saison_id == saison.id }
  end


  protected
  def shifts_sorted_for_status_image
    self.shifts.sort{ |a, b|
      a.saison.eql?(b.saison) ? a.shiftinfo.begin <=> b.shiftinfo.begin : a.saison <=> b.saison
    }
  end

  def create_status_image_stacked
    width, height = 1, 80  # synchronize height with css!
    shift_height = self.shifts.any? ? (height.to_f / self.shifts.count.to_f).round : 0
    result = Image.new(width, height) { self.background_color = "transparent" }

    shift_offset = 0
    self.shifts_sorted_for_status_image.each{ |shift|
      src = Image.new(width, shift_height - 1) {
        self.background_color = shift.free? ? shift.saison.color : "transparent"
        self.size = "#{width}x#{shift_height}+0+#{shift_offset}"
      }
      unless shift.enabled?
        src = src.modulate(1.5, 0.5, 0.95)  # brightness, saturation, hue
      end
      result.composite!(src, 0, shift_offset, Magick::OverCompositeOp)
      shift_offset += shift_height
    }
    result.write(Rails.root + "app/assets/images/" + self.status_image_name)
  end

  # This method heavily depends on certain shiftinfo descriptions and saison names!
  def create_status_image_sorted
    width, height = 80, 80  # synchronize with css!
    geometries = self.geometries_for_sorted_status_image
    #geometries = self.geometries_for_sorted_status_image_pikett
    result = Image.new(width, height) { self.background_color = "transparent" }

    self.shifts.each{ |shift|
      geometry = geometries[shift.shiftinfo]
      src = Image.new(geometry[:w], geometry[:h]) {
        self.background_color = shift.free? ? shift.saison.color : "transparent"
        self.size = geometry[:string]
      }
      unless shift.enabled?
        src = src.modulate(1.5, 0.5, 0.95)  # brightness, saturation, hue
      end
      result.composite!(src, geometry[:x], geometry[:y], Magick::OverCompositeOp)
    }
    result.write Rails.root + "app/assets/images/" + self.status_image_name
  end

  def geometries_for_sorted_status_image_pikett
      sis = self.shifts.collect(&:shiftinfo)
      si = {
        :badi   => sis.select{ |s| s.saison == Saison.badi and not s.description == "Pikett"},
        :pikett => sis.select{ |s| s.saison == Saison.badi and s.description == "Pikett"},
        :kiosk  => sis.select{ |s| s.saison == Saison.kiosk}
      }
      width = {
        :badi   => 30,
        :pikett => 15,
        :kiosk  => 30
      }
      offset_x = {
        :badi   =>  1,
        :pikett => 32,
        :kiosk  => 49
      }

      geo_hash = Hash.new
      [:badi, :pikett, :kiosk].each{ |col|
        if si[col] and si[col].any?
          height = (80 / si[col].size).round
          si[col].sort_by(&:begin).each_with_index do |shiftinfo, i|
            offset_y = i * (height + 1)
            geo_hash[shiftinfo] = {
              :w => width[col],
              :h => height,
              :x => offset_x[col],
              :y => offset_y,
              :string => "#{width[col]}x#{height}+#{offset_x[col]}+#{offset_y}"
            }
          end
        end
      }
      return geo_hash
  end

  def geometries_for_sorted_status_image
      sis = self.shifts.collect(&:shiftinfo)
      si = {
        :badi   => sis.select{ |s| s.saison == Saison.badi },
        :kiosk  => sis.select{ |s| s.saison == Saison.kiosk}
      }
      width = {
        :badi   => 40,
        :kiosk  => 35
      }
      offset_x = {
        :badi   =>  1,
        :kiosk  => 44
      }

      geo_hash = Hash.new
      [:badi, :kiosk].each{ |col|
        if si[col] and si[col].any?
          height = (80 / si[col].size).round
          si[col].sort_by(&:begin).each_with_index do |shiftinfo, i|
            offset_y = i * (height + 1)
            geo_hash[shiftinfo] = {
              :w => width[col],
              :h => height,
              :x => offset_x[col],
              :y => offset_y,
              :string => "#{width[col]}x#{height}+#{offset_x[col]}+#{offset_y}"
            }
          end
        end
      }
      return geo_hash
  end

  def create_status_image_overlapping
    width, height = 1, 80  # synchronize height with css!
    min, max = Saison.daytime_limits
    allday = (max-min).to_f
    result = Image.new(width, height) { self.background_color = "transparent" }

    self.shifts.select(&:enabled).sort_by(&:saison).each { |shift|  # sorting => yellow first
      shift_height = ((shift.duration           ) / allday * height).round
      shift_offset = ((shift.time_to_begin - min) / allday * height).round
      #src = Image.read("gradient:green-transparent") {...}[0]
      src = Image.new(width, shift_height) {
        self.background_color = shift.free? ? shift.saison.color : "transparent"
        self.size = "#{width}x#{shift_height}+0+#{shift_offset}"
      }

      result.composite!(src, 0, shift_offset, Magick::OverCompositeOp)
    }
    #result = result.blur_image(0,3)

    result.write Rails.root + "app/assets/images/" + self.status_image_name
  end

end

