class AddSecondaryAndCollegeToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :phases_list_secondary_and_college, :boolean, default: false, null: false
  end
end
