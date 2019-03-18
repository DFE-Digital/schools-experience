class AddIttWebsiteFieldToBookingsSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_schools, :itt_website, :string, null: true
  end
end
