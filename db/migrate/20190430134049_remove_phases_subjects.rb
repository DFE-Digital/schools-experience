class RemovePhasesSubjects < ActiveRecord::Migration[5.2]
  def change
    drop_table :schools_on_boarding_phase_subjects do |t|
      t.bigint "schools_school_profile_id"
      t.bigint "bookings_phase_id"
      t.bigint "bookings_subject_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["bookings_phase_id"], name: "index_schools_on_boarding_phase_subjects_on_bookings_phase_id"
      t.index ["bookings_subject_id"], name: "index_schools_on_boarding_phase_subjects_on_bookings_subject_id"
      t.index ["schools_school_profile_id"], name: "index_phase_subjects_on_school_profile_id"
    end
  end
end
