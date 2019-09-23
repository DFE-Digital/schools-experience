class AddViewedAtToBookingsPlacementRequestCancellations < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_request_cancellations, :viewed_at, :datetime
  end
end
