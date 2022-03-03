class SeparateCandidateDressCode < ActiveRecord::Migration[6.1]
  def change
    add_column :schools_school_profiles, :candidate_dress_code_step_completed, :boolean, null: true, default: false
    rename_column :schools_school_profiles, :candidate_experience_detail_business_dress, :candidate_dress_code_business_dress
    rename_column :schools_school_profiles, :candidate_experience_detail_cover_up_tattoos, :candidate_dress_code_cover_up_tattoos
    rename_column :schools_school_profiles, :candidate_experience_detail_remove_piercings, :candidate_dress_code_remove_piercings
    rename_column :schools_school_profiles, :candidate_experience_detail_smart_casual, :candidate_dress_code_smart_casual
    rename_column :schools_school_profiles, :candidate_experience_detail_other_dress_requirements, :candidate_dress_code_other_dress_requirements
    rename_column :schools_school_profiles, :candidate_experience_detail_other_dress_requirements_detail, :candidate_dress_code_other_dress_requirements_detail
  end
end
