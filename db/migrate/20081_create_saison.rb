class CreateSaison < ActiveRecord::Migration
  def self.up
    create_table :weeks do |t|
      t.integer :number
      t.references :person

      t.timestamps
    end
    
    create_table :days do |t|
      t.belongs_to :week
      t.date :date

      # no timestamps, since days are automatically created when creating a week
    end

    create_table :shifts do |t|
      # belongs_to is just an alias for references
      t.belongs_to :day
      t.references :shiftinfo
      t.references :person
      t.boolean :enabled, :default => true

      t.timestamps
    end
    
    create_table :shiftinfos do |t|
      t.string :description
      t.time :begin
      t.time :end

      t.timestamps
    end
  end

  def self.down
    drop_table :shiftinfos
    drop_table :shifts
    drop_table :days
    drop_table :weeks
  end
end
