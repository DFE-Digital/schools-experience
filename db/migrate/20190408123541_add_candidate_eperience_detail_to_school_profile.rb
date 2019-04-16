class AddCandidateEperienceDetailToSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_experience_detail_business_dress, :boolean, default: false
    add_column :schools_school_profiles, :candidate_experience_detail_cover_up_tattoos, :boolean, default: false
    add_column :schools_school_profiles, :candidate_experience_detail_remove_piercings, :boolean, default: false
    add_column :schools_school_profiles, :candidate_experience_detail_smart_casual, :boolean, default: false
    add_column :schools_school_profiles, :candidate_experience_detail_other_dress_requirements, :boolean, default: false
    add_column :schools_school_profiles, :candidate_experience_detail_other_dress_requirements_detail, :string
    add_column :schools_school_profiles, :candidate_experience_detail_parking_provided, :boolean
    add_column :schools_school_profiles, :candidate_experience_detail_parking_details, :string
    add_column :schools_school_profiles, :candidate_experience_detail_nearby_parking_details, :string
    add_column :schools_school_profiles, :candidate_experience_detail_disabled_facilities, :boolean
    add_column :schools_school_profiles, :candidate_experience_detail_disabled_facilities_details, :string
    add_column :schools_school_profiles, :candidate_experience_detail_start_time, :string
    add_column :schools_school_profiles, :candidate_experience_detail_end_time, :string
    add_column :schools_school_profiles, :candidate_experience_detail_times_flexible, :boolean
  end
end
