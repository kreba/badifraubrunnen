class Shiftinfo < ActiveRecord::Base

  DESCRIPTIONS = %w[ Morgen Nachmittag Abend ]

  belongs_to :saison
  has_many :shifts

  validates :saison, :description, :begin, :end, presence: true
  validates :description, inclusion: {in: Shiftinfo::DESCRIPTIONS, allow_nil: true}
  
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
