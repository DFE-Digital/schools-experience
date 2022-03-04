class AllowBookingsPlacementDateVirtualToBeNull < ActiveRecord::Migration[6.1]
  def up
    change_column :bookings_placement_dates, :virtual, :boolean, null: true
  end

  def down
    change_column :bookings_placement_dates, :virtual, :boolean, null: false
  end
end
