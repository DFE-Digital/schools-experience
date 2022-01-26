class SetStartAvailabilityOffsetToMaximumForExistingDates < ActiveRecord::Migration[6.1]
  def up
    Bookings::PlacementDate.update_all(start_availability_offset: 180)
  end

  def down; end
end
