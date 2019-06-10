class AddExtraDetailsToBookingsPlacementRequestCancellations < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_request_cancellations, :extra_details, :text
  end
end
