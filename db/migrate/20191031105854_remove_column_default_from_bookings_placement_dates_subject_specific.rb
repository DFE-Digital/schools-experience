class RemoveColumnDefaultFromBookingsPlacementDatesSubjectSpecific < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_placement_dates, :supports_subjects, :boolean, null: true, default: nil
  end
end
