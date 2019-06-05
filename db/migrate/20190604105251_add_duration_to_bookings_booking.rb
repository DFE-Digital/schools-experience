class AddDurationToBookingsBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_bookings, :duration, :integer, default: 1, null: false
  end
end
