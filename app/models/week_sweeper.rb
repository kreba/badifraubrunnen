class WeekSweeper < ActionController::Caching::Sweeper
  observe Week, Day, Shift

  #alias_method :after_save, :clear_days_cache
  def after_save( record )
    week = case record
             when Week  then record
             when Day   then record.week
             when Shift then record.day.week
             else raise "Can't handle objects of type #{record.class}. Expecting Day, Week or Shift."
           end
    clear_days_cache(week) unless week.nil?
  end
  
  def clear_days_cache( week )
    expire_fragment %r{week_#{week.number}_}
    # this matches fragments for the week's
    #  - row in the weeks_table          (e.g. week_28_row_BKbw)
    #  - day tooltips in the weeks_table (e.g. week_28_tooltips_BKbw)
    #  - plans (one for each saison)     (e.g. week_28_plans_BKbw)
  end

end
