autoload :Magick, 'RMagick'

class Day < ApplicationRecord
  # Authorization plugin
  acts_as_authorizable; include AutHack

  belongs_to :week, touch: true
  has_many :shifts, dependent: :destroy

  accepts_nested_attributes_for :shifts, allow_destroy: true

  validates_associated :shifts
  validates_presence_of :date

  def shift_attributes=( attrs ) # invoked on an update (that is, on submitting an update form)
    # assert existance
    self.shifts.update(attrs.keys, attrs.values)
    #self.create_status_image is invoked on a shift update
  end

  def date_str fmt = '%A %d.%m.%Y'
    I18n.l self.date, format: fmt
  end

  # intended use: my_day.plus  1.day
  # or            my_day.minus 1.week
  def plus( time )
    Day.find_by date: self.date + time
  end
  def minus( time )
    Day.find_by date: self.date - time
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
    self.shifts.includes(:shiftinfo).select { |shift| shift.shiftinfo.saison_id == saison.id }
  end

end

