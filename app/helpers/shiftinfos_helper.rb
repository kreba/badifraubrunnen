module ShiftinfosHelper
  def full_descr( shiftinfo )
    shiftinfo.description + " (" + shiftinfo.times_str + ")"
  end
end
