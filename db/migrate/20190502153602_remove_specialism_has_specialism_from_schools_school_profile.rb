class RemoveSpecialismHasSpecialismFromSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    remove_column :schools_school_profiles, :specialism_has_specialism, :boolean
  end
end
