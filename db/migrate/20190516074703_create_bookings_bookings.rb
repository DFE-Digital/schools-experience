class CreateBookingsBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_bookings do |t|
      t.date :date, null: false
      t.integer :bookings_subject_id, null: false
      t.integer :bookings_placement_request_id, null: false
      t.integer :bookings_school_id, null: false
      t.timestamps
    end

    add_index :bookings_bookings, :bookings_subject_id
    add_index :bookings_bookings, :bookings_placement_request_id, unique: true
    add_index :bookings_bookings, :bookings_school_id

    add_foreign_key :bookings_bookings, :bookings_subjects
    add_foreign_key :bookings_bookings, :bookings_placement_requests
    add_foreign_key :bookings_bookings, :bookings_schools
  end
end
