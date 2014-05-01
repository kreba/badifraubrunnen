class AddOffsetToShiftinfo < ActiveRecord::Migration
  def change
    add_column :shiftinfos, :offset, :time
  end
end
