class RemoveAvailabilityDescriptionAndPreferenceFromSchoolsProfile < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools_school_profiles, :availability_description_description, :text
    remove_column :schools_school_profiles, :availability_preference_fixed, :boolean
  end
end
