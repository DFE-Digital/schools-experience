class AddOnlineToBookingsPlacementDates < ActiveRecord::Migration[6.0]
  def up
    # Existing PlacementDates should not be online, new ones should default to online
    change_table :bookings_placement_dates, bulk: true do |t|
      t.boolean :virtual, null: false, default: false
    end

    change_column_default :bookings_placement_dates, :virtual, nil
  end

  def down
    remove_column :bookings_placement_dates, :virtual
  end
end
