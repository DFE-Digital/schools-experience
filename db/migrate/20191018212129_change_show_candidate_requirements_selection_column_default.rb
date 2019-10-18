class ChangeShowCandidateRequirementsSelectionColumnDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :schools_school_profiles, :show_candidate_requirements_selection, true
  end
end
