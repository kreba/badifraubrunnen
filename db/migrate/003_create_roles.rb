class CreateRoles < ActiveRecord::Migration

  def self.up
    create_table :people_roles, :id => false, :force => true  do |t|
      t.references :person, :role
      t.timestamps
    end

    create_table :roles, :force => true do |t|
      t.string  :name, :authorizable_type, :limit => 40
      t.integer :authorizable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
    drop_table :people_roles
  end

end
