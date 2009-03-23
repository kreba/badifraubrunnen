class Shiftinfo < ActiveRecord::Base
  has_many :shifts
  
  # Authorization plugin
  acts_as_authorizable
  
  validates_presence_of :description, :begin, :end
  validates_length_of :description, :within => 1..10
  
#  attr_accessible :description, :begin, :end, :shifts

  def times_str
    return self.begin.strftime( '%H:%M' ) + ' - ' + self.end.strftime( '%H:%M' )
  end
end
