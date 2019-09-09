class AddCandidateRequirementsSelectionStepCompletedToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_requirements_selection_step_completed, :boolean, default: false
  end
end
