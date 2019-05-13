class AddPlacementDateIdToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_requests, :bookings_placement_date_id, :integer, null: true
    add_index :bookings_placement_requests, :bookings_placement_date_id
    add_foreign_key :bookings_placement_requests, :bookings_placement_dates
  end
end
