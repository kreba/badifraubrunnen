class AddEnabledFlagToWeek < ActiveRecord::Migration
  def self.up
    add_column :weeks, :enabled_saisons, :string, :limit => 3, :default => ''

    Week.all.each{ |week|
      enabled_saisons = Saison.all.select{ |saison|
        week.days.collect(&:shifts).flatten.any?{ |shift| shift.saison.eql?(saison) and shift.enabled? }
      }.collect(&:id).join(Week.enabled_saisons_delimiter)
      week.update_attribute(:enabled_saisons, enabled_saisons)
    }
  end

  def self.down
    remove_column :weeks, :enabled
  end
end
