class RemoveSchoolsSchoolProfilesShowCandidateRequirementsSelection < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools_school_profiles, :show_candidate_requirements_selection, :boolean, default: true
  end
end
