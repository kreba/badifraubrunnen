class Shiftinfo < ActiveRecord::Base

  DESCRIPTIONS = [ 'Morgen', 'Nachmittag', 'Kasse', 'Pikett', 'Wasseraufsicht', 'Abend' ]

  belongs_to :saison
  has_many :shifts

  scope :for_week_and_saison, ->(week, saison){ where(saison_id: saison, id: Shift.where(day_id: week.days).uniq.pluck(:shiftinfo_id)) }

  validates :saison, :description, :begin, :end, presence: true
  validates :description, inclusion: {in: Shiftinfo::DESCRIPTIONS, allow_nil: true}

  def begin_plus_offset
    [self.begin, self.offset].compact.sum(&:seconds_since_midnight)
  end
  def end_plus_offset
    [self.end,   self.offset].compact.sum(&:seconds_since_midnight)
  end

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
