class Shift < ActiveRecord::Base
  belongs_to :day
  belongs_to :shiftinfo
  belongs_to :person
  
  # Authorization plugin
  acts_as_authorizable
  
  validates_presence_of :shiftinfo
  
  after_update  :update_status_image_of_my_day

#  attr_accessible :person, :shiftinfo
#  attr_readonly :day


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

  private
  def update_status_image_of_my_day
    day.create_status_image
  end
end
