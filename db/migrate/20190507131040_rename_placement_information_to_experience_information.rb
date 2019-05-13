class RenamePlacementInformationToExperienceInformation < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings_profiles, :placement_info, :experience_details
  end
end
