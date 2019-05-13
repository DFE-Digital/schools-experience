class AddIndexToBookingsSchoolId < ActiveRecord::Migration[5.2]
  def change
    add_index :schools_school_profiles, :bookings_school_id
  end
end
