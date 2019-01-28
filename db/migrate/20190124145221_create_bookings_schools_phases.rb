class CreateBookingsSchoolsPhases < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_schools_phases do |t|
      t.integer :bookings_school_id, null: false
      t.integer :bookings_phase_id, null: false
      t.timestamps
    end

    add_foreign_key :bookings_schools_phases, :bookings_schools
    add_foreign_key :bookings_schools_phases, :bookings_phases
  end
end
