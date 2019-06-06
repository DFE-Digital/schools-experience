class CreateBookingsCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_candidates do |t|
      t.string :gitis_uuid, limit: 36, null: false

      t.timestamps
    end
    add_index :bookings_candidates, :gitis_uuid, unique: true
  end
end
