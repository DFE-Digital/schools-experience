class AddSubjectSpecifityToExistingBookingsPlacementDates < ActiveRecord::Migration[5.2]
  class Bookings::PlacementDate < ApplicationRecord; end

  def change
    published_at = DateTime.now
    Bookings::PlacementDate
      .where(published_at: nil)
      .update_all(published_at: published_at)
  end
end
