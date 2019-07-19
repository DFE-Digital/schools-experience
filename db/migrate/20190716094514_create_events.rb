class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer :bookings_school_id, null: true
      t.uuid :gitis_uuid, null: true
      t.string :event_type, null: false

      t.integer :recordable_id, null: true
      t.string :recordable_type, null: true

      t.timestamps
    end

    add_foreign_key :events, :bookings_schools

    add_index :events, :bookings_school_id
    add_index :events, :gitis_uuid
  end
end
