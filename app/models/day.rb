require 'RMagick'
include Magick

class Day < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  belongs_to :week, touch: true
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

  # Heroku has a read-only file system, hence we created all status images upfront.
  def create_status_image( shifts = shifts_sorted_for_status_image() )
    img_path = Rails.root + "app/assets/images/" + self.status_image_name(shifts)
    self.create_status_image_stacked(shifts).write(img_path) unless File.exists?(img_path)
  end

  def status_image_name( shifts = shifts_sorted_for_status_image() )
    combined_status_str = shifts.collect(&:status_str).join
    "day_status_#{combined_status_str}.png"
  end

  def date_str fmt = '%A %d.%m.%Y'
    return self.date.strftime( fmt )
    # TODO: do better localization of weekday names
  end

  # intended use: my_day.plus  1.day
  # or            my_day.minus 1.week
  def plus( time )
    Day.find_by_date( self.date + time )
  end
  def minus( time )
    Day.find_by_date( self.date - time )
  end

  def timely_active?
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
  
  # shift.shiftinfo.saison.id
  # shift.shiftinfo.begin
  def shifts_sorted_for_status_image
    self.shifts.includes(shiftinfo: :saison).sort{ |a, b|
      (a.saison.id == b.saison.id) ?
        a.shiftinfo.begin <=> b.shiftinfo.begin :
        a.saison.id <=> b.saison.id
    }
  end

  # shift.free?        (shift.person_id)
  # shift.disabled?    (shift.enabled)
  # shift.saison.color 
  def create_status_image_stacked( shifts = shifts_sorted_for_status_image() )
    img_width, img_height = 1, 80  # synchronize height with css!
    result = Image.new(img_width, img_height) { background_color = "transparent" }
    return result if shifts.none?

    shift_height = (img_height.to_f / shifts.count.to_f).round
    shift_offset = 1
    shifts.each{ |shift|
      src = Image.new(img_width, shift_height - 1) {
        background_color = shift.free? ? shift.saison.color : "transparent"
        size = "#{img_width}x#{shift_height}+0+#{shift_offset}"
      }
      if shift.disabled?
        src = src.modulate(1.5, 0.5, 0.95)  # brightness, saturation, hue
      end
      result.composite!(src, 0, shift_offset, Magick::OverCompositeOp)
      shift_offset += shift_height
    }
    
    result
  end

end

