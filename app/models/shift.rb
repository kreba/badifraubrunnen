class Shift < ApplicationRecord

  # Authorization plugin – Why?!
  acts_as_authorizable; include AutHack

  belongs_to :shiftinfo
  belongs_to :day
  belongs_to :person, optional: true

  delegate :saison, :saison=, :times_str,  to: :shiftinfo  # allow_nil: true


  def time_to_begin
    shiftinfo.begin.seconds_since_midnight
  end
  def time_to_end
    shiftinfo.end.seconds_since_midnight
  end
  def duration
    time_to_end - time_to_begin
  end

  def status
    if !free?
      :taken
    elsif !enabled? || !timely_active?
      :disabled
    else
      :free
    end
  end

  def disabled?
    !enabled?
  end
  def free?
    person_id.nil?
  end
  def forget_person!
    update_attribute :person, nil
  end

  def timely_active?
    !day.date.past? &&
    day.date.between?(saison.begin, saison.end)
  end

  def can_staff_sign_up?
    enabled? and free? and timely_active?
  end
end
