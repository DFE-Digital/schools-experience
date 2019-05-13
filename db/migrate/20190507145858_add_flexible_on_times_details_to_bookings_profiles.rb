class AddFlexibleOnTimesDetailsToBookingsProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_profiles, :flexible_on_times_details, :text
  end
end
