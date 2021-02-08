class AddOnlineToBookingsPlacementDates < ActiveRecord::Migration[6.0]
  def up
    # Existing PlacementDates should not be online, new ones should default to online
    add_column :bookings_placement_dates, :virtual, :boolean, null: false, default: false
    change_column :bookings_placement_dates, :virtual, :boolean, null: false, default: nil
  end

  def down
    remove_column :bookings_placement_dates, :virtual
  end
end
