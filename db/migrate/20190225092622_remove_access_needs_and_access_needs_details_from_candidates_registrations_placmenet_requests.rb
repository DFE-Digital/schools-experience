class RemoveAccessNeedsAndAccessNeedsDetailsFromCandidatesRegistrationsPlacmenetRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :candidates_registrations_placement_requests, :access_needs
    remove_column :candidates_registrations_placement_requests, :access_needs_details
  end
end
