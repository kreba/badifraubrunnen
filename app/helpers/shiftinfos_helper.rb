module ShiftinfosHelper

  def full_descr( shiftinfo, format = "%s (%s)" )
    (format % [h(shiftinfo.description), shiftinfo.times_str]).html_safe
  end

end
