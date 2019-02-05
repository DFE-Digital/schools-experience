class AddPositionToBookingsPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_phases, :position, :integer
    add_index :bookings_phases, :position, unique: true
  end
end
