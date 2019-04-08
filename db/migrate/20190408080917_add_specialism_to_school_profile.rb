class AddSpecialismToSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :specialism_has_specialism, :boolean
    add_column :schools_school_profiles, :specialism_details, :text
  end
end
