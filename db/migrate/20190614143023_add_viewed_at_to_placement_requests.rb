class AddViewedAtToPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_requests, :viewed_at, :timestamp, null: true, default: nil
  end
end
