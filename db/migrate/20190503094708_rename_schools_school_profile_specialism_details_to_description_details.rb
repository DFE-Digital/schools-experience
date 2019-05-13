class RenameSchoolsSchoolProfileSpecialismDetailsToDescriptionDetails < ActiveRecord::Migration[5.2]
  def change
    rename_column :schools_school_profiles, :specialism_details, :description_details
  end
end
