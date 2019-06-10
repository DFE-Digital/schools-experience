class AddAcceptedAtToBookingsBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_bookings, :accepted_at, :timestamp, null: true
  end
end
