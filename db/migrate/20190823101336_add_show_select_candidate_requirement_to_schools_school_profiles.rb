class AddShowSelectCandidateRequirementToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :show_candidate_requirements_selection, :boolean, default: false
  end
end
