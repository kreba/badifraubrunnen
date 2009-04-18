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

      result = result.composite(src, 0, shift_offset, Magick::OverCompositeOp)
    }
    #result = result.blur_image(0,3)

    result.write RAILS_ROOT + "/public/images/" + self.status_image_name
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
    !self.date.past? and
    Saison.all.any?{ |saison| self.date.between? saison.begin, saison.end }
    #self.shifts.any?(&:active?)
  end

  def find_shifts_by_saison( saison )
    self.shifts.all.select{ |shift| shift.shiftinfo.saison.eql? saison }
  end

  protected
  def destroy_all_shifts
    self.shifts.each { |shift| shift.destroy() }
  end

end
