class AddEdubaseIdToBookingsPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_phases, :edubase_id, :integer
  end
end
