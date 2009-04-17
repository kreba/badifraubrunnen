class Shiftinfo < ActiveRecord::Base
  # Authorization plugin
  #acts_as_authorizable  #  TODO: Why should it??

  belongs_to :saison
  has_many :shifts
  
  # after_update :update_status_image_of_all_days_of_associated_shifts

  validates_presence_of :saison
  validates_presence_of :description, :begin, :end
  validates_length_of :description, :within => 1..10
  
#  attr_accessible :description, :begin, :end, :shifts
#  attr_protected :saison

  def times_str
    return self.begin.strftime( '%H:%M' ) + ' - ' + self.end.strftime( '%H:%M' )
  end

  def self.list
    Shiftinfo.all.collect{|si| "%2d: %6s, %s - %s  %s"% [si.id, si.description, si.begin.strftime("%X"), si.end.strftime("%X"), si.saison.name]}
  end

  private
  def update_status_image_of_all_days_of_associated_shifts
    shifts.each { |shift| shift.day.create_status_image }
  end
end
