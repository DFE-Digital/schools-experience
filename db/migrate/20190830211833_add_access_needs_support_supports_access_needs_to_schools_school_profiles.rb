class AddAccessNeedsSupportSupportsAccessNeedsToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :access_needs_support_supports_access_needs, :boolean
  end
end
