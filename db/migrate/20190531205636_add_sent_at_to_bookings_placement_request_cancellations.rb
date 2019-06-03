class AddSentAtToBookingsPlacementRequestCancellations < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_request_cancellations, :sent_at, :datetime
  end
end
