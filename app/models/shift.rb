class Shift < ActiveRecord::Base
  belongs_to :day
  belongs_to :shiftinfo
  belongs_to :person
  
  # Authorization plugin
  acts_as_authorizable
  
  validates_presence_of :shiftinfo
  
#  attr_accessible :person, :shiftinfo
#  attr_readonly :day

  def free?
    return person == nil
  end
  
  def forget_person!
    self.person = nil
  end
  
  def times_str
    return shiftinfo.times_str
  end
  
  def mins_to_begin
    return shiftinfo.begin.hour * 60 + shiftinfo.begin.min
  end
  def mins_to_end
    return shiftinfo.end.hour * 60 + shiftinfo.end.min
  end
  def duration
    return mins_to_end - mins_to_begin
  end
end
