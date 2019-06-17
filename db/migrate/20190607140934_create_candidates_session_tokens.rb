class CreateCandidatesSessionTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates_session_tokens do |t|
      t.string :token, null: false
      t.references :candidate, null: false
      t.datetime :expired_at

      t.timestamps
    end
    add_foreign_key :candidates_session_tokens, :bookings_candidates, column: :candidate_id
    add_index :candidates_session_tokens, :token, unique: true
  end
end
