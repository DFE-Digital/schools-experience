class AddAvailabilityPreferenceFixedFlagToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :availability_preference_fixed, :boolean, default: false, null: false
  end
end
