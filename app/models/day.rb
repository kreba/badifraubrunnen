require 'RMagick'
include Magick

class Day < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  belongs_to :week
  has_many :shifts

  after_destroy :destroy_all_shifts

  validates_associated :shifts
  validates_presence_of :date
  # validates_presence_of :week  --  causes problems!

  def shift_attributes=( attrs ) # invoked on an update (that is, on submitting an update form)
    # assert existance
    self.shifts.update(attrs.keys, attrs.values)
    #self.create_status_image is invoked on a shift update
  end

  def status_image_name
    "#{date.strftime '%Y-%m-%d'}.png"
  end

  def create_status_image
    self.create_status_image_stacked
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

  def active?
    self.shifts.select(&:active?).any?
  end
  def enabled?( saison )
    saison_shifts = self.shifts.group_by(&:saison)[saison]
    saison_shifts && saison_shifts.any?(&:enabled?)
  end

  def find_shifts_by_saison( saison )
    # note: self.shifts.find_by_saison  is not possible, since the saison attibute is a delegate to the shiftinfo
    #self.shifts.find(:all, :include => [:person, {:shiftinfo => :saison}]).select { |shift| shift.saison.eql? saison }.sort_by {|s| s.shiftinfo.begin }
    self.shifts.all.select { |shift| shift.saison.eql? saison }
  end


  protected
    def create_status_image_stacked
    width, height = 1, 80  # synchronize height with css!
    shift_height = (height.to_f / self.shifts.count.to_f).round
    result = Image.new(width, height) { self.background_color = "transparent" }

    self.shifts.sort_by(&:saison).each_with_index { |shift, index|
      shift_offset = index * shift_height
      src = Image.new(width, shift_height - 1) {
        self.background_color = (shift.free? and shift.enabled) ? shift.saison.color : "transparent"
        self.size = "#{width}x#{shift_height}+0+#{shift_offset}"
      }
      #result.border!(0,1,"gray")
      result.composite!(src, 0, shift_offset, Magick::OverCompositeOp)
    }
    result.write RAILS_ROOT + "/public/images/" + self.status_image_name
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

    result.write RAILS_ROOT + "/public/images/" + self.status_image_name
  end


  private
  def shifts_str
    return (self.shifts.sort_by {|s| s.shiftinfo.begin}).inject('') {
      |str, shift| str << (shift.free? ? '1' : '0') }
  end

  def destroy_all_shifts
    self.shifts.each { |shift| shift.destroy() }
  end

end
