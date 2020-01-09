class AddMaxBookingsCountToBookingsPlacementDateSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_date_subjects, :max_bookings_count, :integer
  end
end
