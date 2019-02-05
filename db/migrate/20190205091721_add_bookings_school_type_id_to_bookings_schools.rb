class AddBookingsSchoolTypeIdToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :bookings_school_type_id, :integer, null: false
    add_foreign_key :bookings_schools, :bookings_school_types
  end
end
