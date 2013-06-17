class Shiftinfo < ActiveRecord::Base

  belongs_to :saison
  has_many :shifts
  
  # after_update :update_status_image_of_all_days_of_associated_shifts # obsolete on heroku

  validates_presence_of :saison
  validates_presence_of :description, :begin, :end
  validates_length_of :description, within: 1..10
  
#  attr_accessible :description, :begin, :end, :shifts
#  attr_protected :saison

  def times_str
    return self.begin.strftime( '%H:%M' ) + ' - ' + self.end.strftime( '%H:%M' )
  end

  def self.list(cond = {})
    Shiftinfo.all(conditions: cond, include: :saison).collect{|si| "%d: %s, %s  %s"% [si.id, si.description, si.times_str, si.saison.name]}
  end

  private
  def update_status_image_of_all_days_of_associated_shifts
    shifts.each { |shift| shift.day.create_status_image }
  end
end
