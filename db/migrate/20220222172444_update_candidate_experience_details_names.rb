class UpdateCandidateExperienceDetailsNames < ActiveRecord::Migration[6.1]
  def change
    rename_column :schools_school_profiles, :candidate_experience_detail_start_time, :candidate_experience_schedule_start_time
    rename_column :schools_school_profiles, :candidate_experience_detail_end_time, :candidate_experience_schedule_end_time
    rename_column :schools_school_profiles, :candidate_experience_detail_times_flexible, :candidate_experience_schedule_times_flexible
    rename_column :schools_school_profiles, :candidate_experience_detail_times_flexible_details, :candidate_experience_schedule_times_flexible_details
  end
end
