class MakeBookingsProfileSchoolIdUnique < ActiveRecord::Migration[5.2]
  def change
    remove_index :bookings_profiles, :school_id
    add_index :bookings_profiles, :school_id, unique: true
  end
end
