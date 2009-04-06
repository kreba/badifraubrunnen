module WeeksHelper

  def tooltip_for( day )
    shifts = day.shifts.sort_by {|s| s.shiftinfo.begin}
    lines = shifts.collect {|shift| "#{shift.shiftinfo.description}: #{shift.free? ? 'frei' : shift.person.name}"}
    return lines.join(' ··· ')
    #return "<html>#{lines.join('<br/>')}</html>"
  end

  def phone_str( person )
    "#{person.phone}#{",  "+person.phone2 unless person.phone2.nil? or person.phone2.empty?}"
  end
end
