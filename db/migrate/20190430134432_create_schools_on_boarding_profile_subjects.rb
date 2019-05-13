class CreateSchoolsOnBoardingProfileSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :schools_on_boarding_profile_subjects do |t|
      t.bigint :schools_school_profile_id
      t.index [:schools_school_profile_id], name: 'index_profile_subjects_on_school_profile_id'
      t.bigint :bookings_subject_id
      t.index [:bookings_subject_id], name: 'index_profile_subjects_on_school_profile_i'

      t.timestamps
    end
  end
end
