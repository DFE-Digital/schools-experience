class AddSubjectSpecificToBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :subject_specific, :boolean, default: false, null: false
  end
end
