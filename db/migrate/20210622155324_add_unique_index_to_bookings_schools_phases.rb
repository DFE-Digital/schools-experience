class AddUniqueIndexToBookingsSchoolsPhases < ActiveRecord::Migration[6.1]
  def change
    add_index :bookings_schools_phases,
      %i[bookings_school_id bookings_phase_id],
      unique: true,
      name: "index_bookings_schools_phases_school_id_and_phase_id"
  end
end
