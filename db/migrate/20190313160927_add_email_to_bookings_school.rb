class AddEmailToBookingsSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :contact_email, :string, limit: 64, null: true
  end
end
