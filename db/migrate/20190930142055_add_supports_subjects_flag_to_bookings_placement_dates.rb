class AddSupportsSubjectsFlagToBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_dates, :supports_subjects, :boolean, null: false, default: true
  end
end
