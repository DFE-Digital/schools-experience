class AddAdminContactEmail2ToBookingsProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_profiles, :admin_contact_email2, :string
  end
end
