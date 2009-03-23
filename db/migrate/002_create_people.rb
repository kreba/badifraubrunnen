class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name,             :limit =>  50
      t.string :login,            :limit =>  20
      t.string :phone,            :limit =>  13
      t.string :email,            :limit => 100
      
      t.string :crypted_password, :limit =>  40
      t.string :salt,             :limit =>  40
      t.string :remember_token
      t.datetime :remember_token_expires_at

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
