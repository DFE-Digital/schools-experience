class AddBookingsSubjectsToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :bookings_placement_requests, :bookings_subject, foreign_key: true
  end
end
