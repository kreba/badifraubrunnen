class AddIndices < ActiveRecord::Migration
  def change
    add_index :people,       :login

    add_index :people_roles, [:person_id, :role_id] # Is also index for just :person_id
    add_index :roles,        :authorizable_id

    add_index :weeks,        :number

    add_index :days,         :week_id
    add_index :days,         :date

    add_index :shifts,       [:day_id, :shiftinfo_id] # Is also index for just :day_id
    add_index :shifts,       :shiftinfo_id

    add_index :shiftinfos,   :saison_id
  end
end
