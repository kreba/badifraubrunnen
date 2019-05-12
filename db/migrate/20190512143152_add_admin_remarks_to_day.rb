class AddAdminRemarksToDay < ActiveRecord::Migration[5.2]
  def change

    add_column :days, :admin_remarks, :string

  end
end
