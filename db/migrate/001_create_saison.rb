class CreateSaison < ActiveRecord::Migration
  def self.up
    create_table :weeks do |t|
      t.integer :number
    end
    
    create_table :days do |t|
      t.belongs_to :week
      t.date :date
    end

    create_table :shifts do |t|
      t.belongs_to :day
      t.references :shiftinfo
      t.references :person
      # belongs_to is just an alias for references
      
      t.timestamps
    end
    
    create_table :shiftinfos do |t|
      t.string :description
      t.time :begin
      t.time :end
    end
  end

  def self.down
    drop_table :shiftinfos
    drop_table :shifts
    drop_table :days
    drop_table :weeks
  end
end
