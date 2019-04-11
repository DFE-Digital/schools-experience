class MakeBookingsSchoolsContactEmailNotNull < ActiveRecord::Migration[5.2]
  def down
    change_column :bookings_schools, :contact_email, :string, limit: 64
  end

  def up
    change_column :bookings_schools, :contact_email, :string, limit: 64, null: false
  end
end
