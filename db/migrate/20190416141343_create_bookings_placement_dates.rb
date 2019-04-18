class CreateBookingsPlacementDates < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_placement_dates do |t|
      t.date :date, null: false
      t.integer :schools_school_profile_id, null: false
      t.timestamps
    end

    add_index :bookings_placement_dates, :schools_school_profile_id
    add_foreign_key :bookings_placement_dates, :schools_school_profiles
  end
end
