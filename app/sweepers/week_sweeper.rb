class WeekSweeper < ActionController::Caching::Sweeper
  observe Week, Day, Shift

  # Guarantees that the associated week's updated-at attribute is set to the current time. 
  # This invalidates all existing cache fragments, since the updated-at value is included in ActiveRecord's default implementation of the cache_key method.
  def after_save( record )
    case record
      when Week  then record.touch
      when Day   then record.week.touch
      when Shift then record.day.week.touch
      else raise "Can't handle objects of type #{record.class}. Expecting Day, Week or Shift."
    end
  end
  

  private

  # Deprecated. Memcache does not support fragment expiration by regex. Instead we are now using cache keys that include the week's updated-at attribute.
  def clear_all_fragments_of_week( record )
    week = case record
             when Week  then record
             when Day   then record.week
             when Shift then record.day.week
             else raise "Can't handle objects of type #{record.class}. Expecting Day, Week or Shift."
           end
    expire_fragment %r{weeks/#{week.id}}
    # this matches fragments for the week's
    #  - row in the weeks_table          (e.g. week_28_row_BKbw)
    #  - day tooltips in the weeks_table (e.g. week_28_tooltips_BKbw)
    #  - plans (one for each saison)     (e.g. week_28_plans_BKbw)
  end

end
