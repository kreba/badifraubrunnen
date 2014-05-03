module ShiftinfosHelper

  def full_descr( shiftinfo, format = '%s (%s)' )
    (format % [h(shiftinfo.description), shiftinfo.times_str]).html_safe
  end

  def shiftinfo_select_label( shiftinfo )
    full_descr( shiftinfo, '%s, %s')
  end

end
