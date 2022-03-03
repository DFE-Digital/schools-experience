class SeparateCandidateParkingInformation < ActiveRecord::Migration[6.1]
  def change
    rename_column :schools_school_profiles, :candidate_experience_detail_parking_provided, :candidate_parking_information_parking_provided
    rename_column :schools_school_profiles, :candidate_experience_detail_parking_details, :candidate_parking_information_parking_details
    rename_column :schools_school_profiles, :candidate_experience_detail_nearby_parking_details, :candidate_parking_information_nearby_parking_details
  end
end
