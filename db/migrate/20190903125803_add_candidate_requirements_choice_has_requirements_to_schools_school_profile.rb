class AddCandidateRequirementsChoiceHasRequirementsToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_requirements_choice_has_requirements, :boolean
  end
end
