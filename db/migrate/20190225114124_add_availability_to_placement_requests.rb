class AddAvailabilityToPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates_registrations_placement_requests, :availability, :text, null: false
  end
end
