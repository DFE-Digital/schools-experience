class AddParkingToBookingsSchoolSearch < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_school_searches, :parking, :boolean
  end
end
