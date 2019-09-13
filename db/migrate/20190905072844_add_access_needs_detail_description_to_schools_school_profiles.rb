class AddAccessNeedsDetailDescriptionToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :access_needs_detail_description, :string
  end
end
