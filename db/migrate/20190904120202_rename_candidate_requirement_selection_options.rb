class RenameCandidateRequirementSelectionOptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools_school_profiles, :candidate_requirements_selection_has_degree, :boolean
    remove_column :schools_school_profiles, :candidate_requirements_selection_working_towards_degree, :boolean

    add_column :schools_school_profiles, :candidate_requirements_selection_not_on_another_training_course, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_has_or_working_towards_degree, :boolean
  end
end
