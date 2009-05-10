module ShiftsHelper
  def person_string_or_free( shift )
    shift.free? ?
      " %s "% (shift.active? ? I18n.t('shifts.free') : '') :
      "#{shift.person.name}<br />#{shift.person.phone}"
  end

  def subscription_link_or_text( shift )
    if shift.free?
      if shift.enabled
        if shift.active?
          link_to( " #{t 'shifts.sign_up'} " , edit_shift_path(shift) )
        end
      else
        content_tag(:span, " - #{t('shifts.no_sign_up')} - ", :style => "color: gray")
      end
    elsif shift.active?
      content_tag(:span, " - #{t('shifts.taken')} - ", :style => "color: gray")
    end
  end
end
