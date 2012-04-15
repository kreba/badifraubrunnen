class Shift < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable  # Why?!

  belongs_to :day
  #has_one :week, through: :day  # unused
  belongs_to :shiftinfo
  # could add  has_one :saison, through: :shiftinfo
  belongs_to :person
  
  after_update :update_status_image_of_my_day

  validates_presence_of :shiftinfo

  attr_protected :enabled
#  attr_accessible :person, :shiftinfo
#  attr_readonly :day
  delegate :saison, :saison=, :times_str,  :to => :shiftinfo  # :allow_nil => true

  def free?
    return person.nil?
  end
  def forget_person!
    self.person = nil
  end

  def time_to_begin
    return shiftinfo.begin.seconds_since_midnight
  end
  def time_to_end
    return shiftinfo.end.seconds_since_midnight
  end
  def duration
    return time_to_end - time_to_begin
  end

  def active?
    !self.day.date.past? &&
    self.day.date.between?(self.saison.begin, self.saison.end)
  end
  def can_staff_sign_up?
    self.enabled? and self.free? and self.active?
  end

  protected
  def update_status_image_of_my_day
    day.create_status_image
  end
end
