class AddUniqueIndexToSchoolsOnBoardingProfileSubjects < ActiveRecord::Migration[6.1]
  def change
    add_index :schools_on_boarding_profile_subjects,
      %i[schools_school_profile_id bookings_subject_id],
      unique: true,
      name: "index_profile_subjects_school_profile_id_and_subject_id"
  end
end
