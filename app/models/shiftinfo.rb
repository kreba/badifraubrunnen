class Shiftinfo < ApplicationRecord

  belongs_to :saison
  has_many :shifts

  scope :for_week_and_saison, ->(week, saison){ where(saison_id: saison, id: Shift.where(day_id: week.days).uniq.pluck(:shiftinfo_id)) }

  validates :description, :begin, :end, presence: true

  def begin_plus_offset
    [read_attribute(:begin), read_attribute(:offset)].compact.sum(&:seconds_since_midnight)
  end
  def end_plus_offset
    [read_attribute(:end  ), read_attribute(:offset)].compact.sum(&:seconds_since_midnight)
  end

  def times_str
    "#{self.begin&.strftime( '%H:%M' )} - #{self.end&.strftime( '%H:%M' )}"
  end

  def self.list(cond = {})
    Shiftinfo.includes(:saison).where(cond).collect{|si| "%2d: %12s, %s  %s"% [si.id, si.description, si.times_str, si.saison.name]}
  end

end
