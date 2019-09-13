class AddAccessNeedsFieldsToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :access_needs_policy_has_access_needs_policy, :boolean
    add_column :schools_school_profiles, :access_needs_policy_url, :string
  end
end
