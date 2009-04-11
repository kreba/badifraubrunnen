module ShiftsHelper
  def person_string_or_free shift
    shift.free? ? " "+I18n.t('shifts.free')+" " : "#{shift.person.name}<br />#{shift.person.phone}"
  end
end
