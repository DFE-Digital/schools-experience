class RemoveAvailabilityFromBookingsProfile < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings_profiles, :fixed_availability, :boolean, null: false
    remove_column :bookings_profiles, :availability_info, :text
  end
end
