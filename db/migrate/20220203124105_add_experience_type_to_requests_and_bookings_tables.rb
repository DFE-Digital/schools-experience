class AddExperienceTypeToRequestsAndBookingsTables < ActiveRecord::Migration[6.1]
  def up
    add_column :bookings_placement_requests, :experience_type, :string, if_not_exists: true
    add_column :bookings_bookings, :experience_type, :string, if_not_exists: true
  end

  def down
    remove_column :bookings_placement_requests, :experience_type, if_exists: true
    remove_column :bookings_bookings, :experience_type, if_exists: true
  end
end
