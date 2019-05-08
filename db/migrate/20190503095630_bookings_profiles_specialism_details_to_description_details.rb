class BookingsProfilesSpecialismDetailsToDescriptionDetails < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings_profiles, :specialism_details, :description_details
  end
end
