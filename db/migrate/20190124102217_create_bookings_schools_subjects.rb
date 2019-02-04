class CreateBookingsSchoolsSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_schools_subjects do |t|
      t.integer :bookings_school_id, null: false
      t.integer :bookings_subject_id, null: false
      t.timestamps
    end

    add_foreign_key :bookings_schools_subjects, :bookings_schools
    add_foreign_key :bookings_schools_subjects, :bookings_subjects
  end
end
