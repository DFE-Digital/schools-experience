class MoveSchoolToBookingsNamespace < ActiveRecord::Migration[5.2]
  def change
    rename_table :schools, :bookings_schools
  end
end
