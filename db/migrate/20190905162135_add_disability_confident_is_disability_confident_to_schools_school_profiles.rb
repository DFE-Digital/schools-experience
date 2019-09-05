class AddDisabilityConfidentIsDisabilityConfidentToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :disability_confident_is_disability_confident, :boolean
  end
end
