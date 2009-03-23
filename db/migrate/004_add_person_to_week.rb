class AddPersonToWeek < ActiveRecord::Migration
  def self.up
    add_column :weeks, :person_id, :integer
#    add_column
  end

  def self.down
    remove_column :weeks, :person_id
  end
end
