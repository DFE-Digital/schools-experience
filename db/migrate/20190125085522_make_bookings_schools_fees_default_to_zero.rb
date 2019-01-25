class MakeBookingsSchoolsFeesDefaultToZero < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_schools, :fee, :integer, default: 0, null: false
  end
end
