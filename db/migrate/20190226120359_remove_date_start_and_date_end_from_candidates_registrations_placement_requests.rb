class RemoveDateStartAndDateEndFromCandidatesRegistrationsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :candidates_registrations_placement_requests, :date_start, :date
    remove_column :candidates_registrations_placement_requests, :date_end, :date
  end
end
