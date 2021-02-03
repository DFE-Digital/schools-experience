class AddExperienceTypeToBookingsSchools < ActiveRecord::Migration[6.0]
  def up
    add_column :bookings_schools, :experience_type, :string
  end

  def down
    drop_column :bookings_schools, :experience_type
  end
end
