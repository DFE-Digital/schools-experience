class RenameCandidatesRegistrationsPlacementRequestsToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    rename_table :candidates_registrations_placement_requests, :bookings_placement_requests
  end
end
