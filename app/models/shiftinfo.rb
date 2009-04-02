class Shiftinfo < ActiveRecord::Base
  has_many :shifts
  
  # Authorization plugin
  acts_as_authorizable
  
  validates_presence_of :description, :begin, :end
  validates_length_of :description, :within => 1..10
  
  after_update  :update_status_image_of_all_days_of_associated_shifts

#  attr_accessible :description, :begin, :end, :shifts

  def times_str
    return self.begin.strftime( '%H:%M' ) + ' - ' + self.end.strftime( '%H:%M' )
  end

  private
  def update_status_image_of_all_days_of_associated_shifts
    shifts.each { |shift| shift.day.create_status_image }
  end
end
