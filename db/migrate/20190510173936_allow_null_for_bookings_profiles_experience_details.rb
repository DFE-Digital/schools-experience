class AllowNullForBookingsProfilesExperienceDetails < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_profiles, :experience_details, :text, null: true
  end
end
