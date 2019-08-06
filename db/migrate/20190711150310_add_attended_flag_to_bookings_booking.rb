class AddAttendedFlagToBookingsBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_bookings, :attended, :boolean, nil: true, default: nil
  end
end
