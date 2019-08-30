class AddIndexToCandidateSessionTokens < ActiveRecord::Migration[5.2]
  def change
    add_index :candidates_session_tokens, [:candidate_id, :expired_at]
  end
end
