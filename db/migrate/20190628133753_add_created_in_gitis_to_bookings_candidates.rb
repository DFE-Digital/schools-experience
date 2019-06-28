class AddCreatedInGitisToBookingsCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_candidates, :created_in_gitis, :boolean, default: false
  end
end
