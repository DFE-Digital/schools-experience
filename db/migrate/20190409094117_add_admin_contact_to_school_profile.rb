class AddAdminContactToSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :admin_contact_full_name, :string
    add_column :schools_school_profiles, :admin_contact_email, :string
    add_column :schools_school_profiles, :admin_contact_phone, :string
  end
end
