class CandidatesRequirementsChoiceHasRequirementsFromSchoolsSchoolProfile < ActiveRecord::Migration[6.1]
  def change
    remove_column :schools_school_profiles, :candidate_requirements_choice_has_requirements, :boolean
  end
end
