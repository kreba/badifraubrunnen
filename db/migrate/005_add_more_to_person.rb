class AddMoreToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :postal_code, :integer
    add_column :people, :location, :string, :limit => 30
    add_column :people, :address,  :string, :limit => 50
    add_column :people, :phone2,   :string, :limit => 13
  end

  def self.down
    remove_column :people, :postal_code
    remove_column :people, :location
    remove_column :people, :address
    remove_column :people, :phone2
  end
end
