class AllowNullsForBookingsPlacementDateSubjectSpecific < ActiveRecord::Migration[5.2]
  def up
    change_column :bookings_placement_dates, :subject_specific, :boolean, default: nil, null: true
  end

  def down
    change_column :bookings_placement_dates, :subject_specific, :boolean, default: false, null: false
  end
end
