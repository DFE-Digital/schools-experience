class AddFeesToBookingsSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :fee, :integer, null: true
  end
end
