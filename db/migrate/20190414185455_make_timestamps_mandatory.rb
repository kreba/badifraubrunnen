class MakeTimestampsMandatory < ActiveRecord::Migration[5.0]
  def change
    change_column_null "people",       "created_at", false, "2008-04-27 00:00:00"
    change_column_null "people",       "updated_at", false, "2008-04-27 00:00:00"
    change_column_null "people_roles", "created_at", false, "2008-04-27 00:00:00"
    change_column_null "people_roles", "updated_at", false, "2008-04-27 00:00:00"
    change_column_null "saisons",      "created_at", false, "2008-04-27 00:00:00"
    change_column_null "saisons",      "updated_at", false, "2008-04-27 00:00:00"
    change_column_null "shiftinfos",   "created_at", false, "2008-04-27 00:00:00"
    change_column_null "shiftinfos",   "updated_at", false, "2008-04-27 00:00:00"
    change_column_null "shifts",       "created_at", false, "2008-04-27 00:00:00"
    change_column_null "shifts",       "updated_at", false, "2008-04-27 00:00:00"
    change_column_null "weeks",        "created_at", false, "2008-04-27 00:00:00"
    change_column_null "weeks",        "updated_at", false, "2008-04-27 00:00:00"
  end
end
