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

  def find_shifts_by_saison( saison )
    # note: self.shifts.find_by_saison  is not possible, since the saison attibute is a delegate to the shiftinfo
#    self.shifts.find(:all, :include => [:person, {:shiftinfo => :saison}]).select { |shift| shift.saison.eql? saison }.sort_by {|s| s.shiftinfo.begin }
    self.shifts.all.select { |shift| shift.saison.eql? saison }.sort_by {|s| s.shiftinfo.begin }
  end
  def shifts_mapped_by_saison
    shifts = {}
    Saison.all.each{ |saison|
      shifts[saison] = self.find_shifts_by_saison(saison)
    }
    shifts
  end

  def status_image_name( saison )
    "#{saison.name}_#{date.strftime '%Y-%m-%d'}.png"
  end

  def create_status_image( saison )
    width, height = 1, 90  # synchronize height with css!
    min, max = saison.daytime_limits
    allday = (max-min).to_f
    result = Image.new(width, height) { self.background_color = "transparent" }

    self.shifts.select{|s|s.saison.eql?(saison)}.each { |shift|
      shift_height = ((shift.duration           ) / allday * height).round
      shift_offset = ((shift.time_to_begin - min) / allday * height).round
      #src = Image.read("gradient:green-transparent") {...}[0]
      src = Image.new(width, shift_height) {
        self.background_color = shift.free? ? saison.color : "transparent"
        self.size = "#{width}x#{shift_height}+0+#{shift_offset}"
      }
      
      result = result.composite(src, 0, shift_offset, Magick::OverCompositeOp)
    }
    #result = result.blur_image(0,3)

    result.write RAILS_ROOT + "/public/images/" + status_image_name(saison)
  end
  
  def date_str fmt = '%A %d.%m.%Y'
    return self.date.strftime( fmt )
    # TODO: do better localization of weekday names
  end

  # intended use: my_day.plus 1.day
  def plus( time )
    return Day.find_by_date( self.date + time )
  end

  # intended use: my_day.minus 1.week
  def minus( time )
    return Day.find_by_date( self.date - time )
  end

  def active?
    self.shifts.select(&:active?).any?
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
