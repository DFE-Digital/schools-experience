class ChangeEventGitisUuidToBookingsCandidateId < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :gitis_uuid, :uuid

    add_column :events, :bookings_candidate_id, :integer, null: true

    add_foreign_key :events, :bookings_candidates
  end
end
