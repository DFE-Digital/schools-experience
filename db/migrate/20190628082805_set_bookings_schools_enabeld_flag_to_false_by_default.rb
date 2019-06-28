class SetBookingsSchoolsEnabeldFlagToFalseByDefault < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_schools, :enabled, :boolean, default: false
  end
end
