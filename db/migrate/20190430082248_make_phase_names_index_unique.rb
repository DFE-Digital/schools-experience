class MakePhaseNamesIndexUnique < ActiveRecord::Migration[5.2]
  def change
    remove_index :bookings_phases, :name
    add_index :bookings_phases, :name, unique: true
  end
end
