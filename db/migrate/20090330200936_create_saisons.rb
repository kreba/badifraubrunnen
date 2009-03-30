class CreateSaisons < ActiveRecord::Migration
  def self.up
    create_table :saisons do |t|
      t.date :begin
      t.date :end

      t.timestamps
    end
  end

  def self.down
    drop_table :saisons
  end
end
