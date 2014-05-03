module ShiftsHelper
  def person_string_or_free( shift )
    if shift.free?
      shift.timely_active? ? I18n.t('shifts.free') : ''
    else
      "#{person_with_brevet(shift.person)}<br />#{shift.person.phone}".html_safe
    end
  end

  def subscription_link_or_text( shift )
    if shift.free?
      if shift.enabled
        if shift.timely_active?
          link_to( t('shifts.sign_up') , edit_shift_path(shift) )
        end
      else
        content_tag(:span, " - #{t('shifts.no_sign_up')} - ", style: "color: gray")
      end
    elsif shift.timely_active?
      content_tag(:span, " - #{t('shifts.taken')} - ", style: "color: gray")
    end
  end
end
