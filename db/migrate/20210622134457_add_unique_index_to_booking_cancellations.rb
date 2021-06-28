class AddUniqueIndexToBookingCancellations < ActiveRecord::Migration[6.1]
  def up
    remove_index :bookings_placement_request_cancellations, name: "index_cancellations_on_bookings_placement_request_id"
    add_index :bookings_placement_request_cancellations, :bookings_placement_request_id, name: "index_cancellations_on_bookings_placement_request_id", unique: true
  end

  def down
    remove_index :bookings_placement_request_cancellations, name: "index_cancellations_on_bookings_placement_request_id"
    add_index :bookings_placement_request_cancellations, :bookings_placement_request_id, name: "index_cancellations_on_bookings_placement_request_id"
  end
end
