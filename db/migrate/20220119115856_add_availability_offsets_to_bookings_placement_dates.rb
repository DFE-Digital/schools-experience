class AddAvailabilityOffsetsToBookingsPlacementDates < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_placement_dates, :end_availability_offset, :integer, default: 0, null: false
    add_column :bookings_placement_dates, :start_availability_offset, :integer, default: 60, null: false
  end
end
