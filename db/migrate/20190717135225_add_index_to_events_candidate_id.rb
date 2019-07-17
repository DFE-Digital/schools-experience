class AddIndexToEventsCandidateId < ActiveRecord::Migration[5.2]
  def change
    add_index :events, :bookings_candidate_id
  end
end
