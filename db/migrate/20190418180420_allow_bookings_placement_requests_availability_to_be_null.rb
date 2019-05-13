class AllowBookingsPlacementRequestsAvailabilityToBeNull < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_placement_requests, :availability, :text, null: true
  end
end
