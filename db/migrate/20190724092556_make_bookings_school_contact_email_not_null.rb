class MakeBookingsSchoolContactEmailNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_schools, :contact_email, :string, limit: 64, null: true
  end
end
