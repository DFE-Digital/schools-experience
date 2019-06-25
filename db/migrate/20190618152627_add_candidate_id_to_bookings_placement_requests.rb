class AddCandidateIdToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :bookings_placement_requests, :candidate, index: true
    add_foreign_key :bookings_placement_requests, :bookings_candidates, column: :candidate_id
  end
end
