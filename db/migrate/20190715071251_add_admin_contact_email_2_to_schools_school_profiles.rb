class AddAdminContactEmail2ToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :admin_contact_email2, :string
  end
end
