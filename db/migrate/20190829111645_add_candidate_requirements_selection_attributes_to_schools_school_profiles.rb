class AddCandidateRequirementsSelectionAttributesToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_requirements_selection_on_teacher_training_course, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_has_degree, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_working_towards_degree, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_live_locally, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_maximum_distance_from_school, :integer
    add_column :schools_school_profiles, :candidate_requirements_selection_other, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_other_details, :text
  end
end
