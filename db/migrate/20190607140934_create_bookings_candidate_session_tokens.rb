class CreateBookingsCandidateSessionTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_candidate_session_tokens do |t|
      t.string :token, null: false
      t.references :candidate, null: false
      t.datetime :expired_at

      t.timestamps
    end
    add_foreign_key :bookings_candidate_session_tokens, :bookings_candidates, column: :candidate_id
    add_index :bookings_candidate_session_tokens, :token, unique: true
  end
end
