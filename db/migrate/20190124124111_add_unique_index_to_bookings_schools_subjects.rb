class AddUniqueIndexToBookingsSchoolsSubjects < ActiveRecord::Migration[5.2]
  def change
    add_index :bookings_schools_subjects,
      %i{bookings_school_id bookings_subject_id},
      unique: true,
      name: "index_bookings_schools_subjects_school_id_and_subject_id"
  end
end
