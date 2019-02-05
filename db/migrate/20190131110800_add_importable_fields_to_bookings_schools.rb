class AddImportableFieldsToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :urn, :integer, null: false
    add_column :bookings_schools, :website, :varchar, limit: 128
    add_column :bookings_schools, :address_1, :varchar, limit: 128, null: false
    add_column :bookings_schools, :address_2, :varchar, limit: 128, null: true
    add_column :bookings_schools, :address_3, :varchar, limit: 128, null: true
    add_column :bookings_schools, :town, :varchar, limit: 64, null: true
    add_column :bookings_schools, :county, :varchar, limit: 64, null: true
    add_column :bookings_schools, :postcode, :varchar, limit: 8, null: false

    add_index :bookings_schools, :urn, unique: true
  end
end
