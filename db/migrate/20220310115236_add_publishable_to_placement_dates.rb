class AddPublishableToPlacementDates < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_placement_dates, :publishable, :boolean, default: false

    up_only do
      Bookings::PlacementDate.where.not(published_at: nil).update_all(publishable: true)
    end
  end
end
