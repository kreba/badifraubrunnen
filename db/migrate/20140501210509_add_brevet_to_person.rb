class AddBrevetToPerson < ActiveRecord::Migration
  def change
    add_column :people, :brevet, :boolean, null: false, default: false
  end
end
