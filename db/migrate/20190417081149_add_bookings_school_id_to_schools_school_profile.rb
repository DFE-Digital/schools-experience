class AddBookingsSchoolIdToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :bookings_school_id, :integer, null: false
    add_foreign_key :schools_school_profiles, :bookings_schools
    remove_column :schools_school_profiles, :urn, :integer
  end
end
