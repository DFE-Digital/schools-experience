class AddViewCounterToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :views, :integer, default: 0, null: false
  end
end
