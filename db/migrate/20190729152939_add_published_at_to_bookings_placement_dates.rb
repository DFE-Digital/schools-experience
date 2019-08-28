class AddPublishedAtToBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :published_at, :datetime
  end
end
