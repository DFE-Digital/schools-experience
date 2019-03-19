class AddBookingsSchoolSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_school_searches do |t|
      t.string :query, limit: 128
      t.string :location, limit: 128
      t.integer :radius, default: 10
      t.integer :subjects, array: true
      t.integer :phases, array: true
      t.integer :max_fee
      t.integer :page
      t.integer :results, default: 0
      t.geography :coordinates, limit: { srid: 4326, type: "st_point", geographic: true }
      t.timestamps
    end
  end
end
