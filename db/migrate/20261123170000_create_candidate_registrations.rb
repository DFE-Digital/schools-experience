class CreateCandidateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_registrations do |t|
      t.string :uuid, null: false
      # The registration's JSON document exactly as serialised; jsonb would
      # reorder keys and json cannot be upserted
      t.text :registration_data, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :candidate_registrations, :uuid, unique: true
    add_index :candidate_registrations, :expires_at
  end
end
