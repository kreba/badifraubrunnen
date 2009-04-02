require 'RMagick'
include Magick

class Day < ActiveRecord::Base
  after_destroy :destroy_all_shifts
  
  belongs_to :week
  has_many :shifts

  # Authorization plugin
  acts_as_authorizable
  
  validates_associated :shifts
  validates_presence_of :date
  # validates_presence_of :week  --  causes problems!
  
  def shift_attributes=(attrs) # (invoked on an update (that is, on submitting an update form)) (I doubt that)
    # assert existance
    self.shifts.update(attrs.keys, attrs.values)
    self.create_status_image
  end
  
  def status_image_path
    "/images/#{date.strftime '%Y-%m-%d'}.png"
  end

  def create_status_image
    width, height = 1, 90  # synchronize height with css!
    min, max = ShiftinfosHelper.daytime_limits
    allday = (max-min).to_f
    result = Image.new(width, height - 1 ) { self.background_color = "transparent" }

    shifts.each { |shift|
      shift_height = shift.duration / allday * height
      shift_offset = (shift.time_to_begin - min) / allday * height
      #src = Image.read("gradient:green-transparent") {...}[0]
      src = Image.new(width, shift_height) {
        self.background_color = shift.free? ? "green2" : "transparent"
        self.size = "#{width}x#{shift_height}+0+#{shift_offset}"
      }

      result = result.composite(src, 0, shift_offset, Magick::OverCompositeOp)
    }
    result = result.blur_image(0,3)
    result.write "/home/kreba/Dokumente/dev/badi2010/public" << status_image_path # TODO: system independent!!!

  end
  
  def date_str fmt = '%A %d.%m.%Y'
    return self.date.strftime( fmt )
    # TODO: do better localization of weekday names
  end

  def yesterday
    return Day.find_by_date( self.date.yesterday );
  end

  def tomorrow
    return Day.find_by_date( self.date.tomorrow );
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
