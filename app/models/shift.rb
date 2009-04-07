class Shift < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  belongs_to :day
  belongs_to :shiftinfo
  belongs_to :person
  
  after_update  :update_status_image_of_my_day

  validates_presence_of :shiftinfo
  
#  attr_accessible :person, :shiftinfo
#  attr_readonly :day
  delegate :saison, :saison=,   :to => :shiftinfo  # :allow_nil => true

  def free?
    return person.nil?
  end
  def forget_person!
    self.person = nil
  end

  def times_str
    return shiftinfo.times_str
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
    in_active_saison = (self.saison.begin..self.saison.end).include? self.day.date
    self.enabled and in_active_saison and !self.day.date.past?
  end

  private
  def update_status_image_of_my_day
    day.create_status_image(saison)
  end
end
