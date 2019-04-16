class AddAvailabilityDescriptionToSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :availability_description_description, :text
  end
end
