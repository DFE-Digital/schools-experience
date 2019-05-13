class AddEnabledFlagToBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :active, :boolean, default: true, null: false
  end
end
