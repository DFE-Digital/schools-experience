class AddSupportsSubjectFlagToBookingsPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_phases, :supports_subjects, :boolean, default: true, null: false
  end
end
