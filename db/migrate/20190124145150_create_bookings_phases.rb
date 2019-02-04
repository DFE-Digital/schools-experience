class CreateBookingsPhases < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_phases do |t|
      t.string :name, limit: 32
      t.timestamps
    end

    add_index :bookings_phases, :name
  end
end
