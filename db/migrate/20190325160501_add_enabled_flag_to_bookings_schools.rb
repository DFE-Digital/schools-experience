class AddEnabledFlagToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :enabled, :boolean, default: true, null: false
  end
end
