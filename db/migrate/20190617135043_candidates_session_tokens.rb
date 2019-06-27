class CandidatesSessionTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_candidates, :confirmed_at, :datetime, index: true
    add_column :candidates_session_tokens, :confirmed_at, :datetime, index: true
  end
end
