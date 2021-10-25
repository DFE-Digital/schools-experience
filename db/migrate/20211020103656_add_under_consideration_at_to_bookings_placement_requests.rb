class AddUnderConsiderationAtToBookingsPlacementRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_placement_requests, :under_consideration_at, :timestamp, null: true
  end
end
