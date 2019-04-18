class AddExperienceOutlineToSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :experience_outline_candidate_experience, :text
    add_column :schools_school_profiles, :experience_outline_provides_teacher_training, :boolean
    add_column :schools_school_profiles, :experience_outline_teacher_training_details, :text
    add_column :schools_school_profiles, :experience_outline_teacher_training_url, :string
  end
end
