class AddDurationToPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :duration, :integer, default: 1, null: false
  end
end
