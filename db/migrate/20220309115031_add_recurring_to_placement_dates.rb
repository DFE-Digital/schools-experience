class AddRecurringToPlacementDates < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_placement_dates, :recurring, :boolean, default: false
  end
end
