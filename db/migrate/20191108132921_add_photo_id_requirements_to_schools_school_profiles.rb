class AddPhotoIdRequirementsToSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :candidate_requirements_selection_provide_photo_identification, :boolean
    add_column :schools_school_profiles, :candidate_requirements_selection_photo_identification_details, :text
  end
end
