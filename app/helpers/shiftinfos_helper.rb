module ShiftinfosHelper
  def full_descr( shiftinfo )
    shiftinfo.description + " (" + shiftinfo.times_str + ")"
  end

protected
  def self.daytime_limits
    times = Shiftinfo.find :all
    min = times.min_by(&:begin).begin.seconds_since_midnight
    max = times.max_by(&:end).end.seconds_since_midnight
    return min, max
  end
end
