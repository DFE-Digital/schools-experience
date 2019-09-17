class MakeAvailabilityPreferenceFixedNotNull < ActiveRecord::Migration[5.2]
  def up
    change_column :bookings_schools, :availability_preference_fixed, :boolean, null: true
  end
end
