class AddMaxBookingsCountToBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :max_bookings_count, :integer
  end
end
