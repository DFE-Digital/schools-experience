class AddDbsToBookingsSchoolSearch < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings_school_searches, :dbs_policies, :integer, array: true
  end
end
