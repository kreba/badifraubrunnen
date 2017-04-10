class Shift < ActiveRecord::Base
  STATUS_CHARS = {
    free:     'F',
    taken:    'T',
    disabled: '0'
  }

  # Authorization plugin – Why?!
  acts_as_authorizable; include AutHack

  belongs_to :shiftinfo
  belongs_to :day
  belongs_to :person

  after_update :update_status_image_of_my_day

  validates_presence_of :shiftinfo, :day

  delegate :saison, :saison=, :times_str,  to: :shiftinfo  # allow_nil: true


  def time_to_begin
    return shiftinfo.begin.seconds_since_midnight
  end
  def time_to_end
    return shiftinfo.end.seconds_since_midnight
  end
  def duration
    return time_to_end - time_to_begin
  end

  def status_str
    saison_char + status_char
  end
  def saison_char
    saison.name.chars.first.downcase
  end
  def status_char
    if !free?
      STATUS_CHARS[:taken]
    elsif !enabled? || !timely_active?
      STATUS_CHARS[:disabled]
    else
      STATUS_CHARS[:free]
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

  protected
  def update_status_image_of_my_day
    #day.create_status_image
    # We currently deploy to heroku, which requires all static assets to be precompiled.
    # Hence we check in every possible status image.
    # Hence no need for creation here.
  end
end
