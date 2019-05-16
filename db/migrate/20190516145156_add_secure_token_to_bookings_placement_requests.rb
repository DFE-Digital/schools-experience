class AddSecureTokenToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_requests, :token, :string
    add_index :bookings_placement_requests, :token, unique: true
  end
end
