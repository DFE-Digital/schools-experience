class AddBookingsSchoolIdToBookingsCandidateRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_requests, :bookings_school_id, :integer
    add_foreign_key :bookings_placement_requests, :bookings_schools
    add_index :bookings_placement_requests, :bookings_school_id
  end
end
