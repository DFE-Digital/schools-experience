class RemoveAdminContactFullNameFromSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools_school_profiles, :admin_contact_full_name, :string
  end
end
