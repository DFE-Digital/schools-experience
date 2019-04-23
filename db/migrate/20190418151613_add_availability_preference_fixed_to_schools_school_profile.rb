class AddAvailabilityPreferenceFixedToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :availability_preference_fixed, :boolean
  end
end
