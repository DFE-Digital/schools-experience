class LinkBookingsPlacementDatesToBookingsSchools < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :bookings_placement_dates, :schools_school_profiles
    remove_index :bookings_placement_dates, :schools_school_profile_id
    remove_column :bookings_placement_dates, :schools_school_profile_id

    add_column :bookings_placement_dates, :bookings_school_id, :integer, null: false
    add_foreign_key :bookings_placement_dates, :bookings_schools
    add_index :bookings_placement_dates, :bookings_school_id
  end
end
