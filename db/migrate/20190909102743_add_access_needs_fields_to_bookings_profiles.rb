class AddAccessNeedsFieldsToBookingsProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_profiles, :supports_access_needs, :boolean
    add_column :bookings_profiles, :access_needs_description, :text
    add_column :bookings_profiles, :disability_confident, :boolean
    add_column :bookings_profiles, :has_access_needs_policy, :boolean
    add_column :bookings_profiles, :access_needs_policy_url, :string
  end
end
