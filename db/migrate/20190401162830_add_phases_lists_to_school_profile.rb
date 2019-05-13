class AddPhasesListsToSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :phases_list_primary, :boolean, default: false, null: false
    add_column :schools_school_profiles, :phases_list_secondary, :boolean, default: false, null: false
    add_column :schools_school_profiles, :phases_list_college, :boolean, default: false, null: false
  end
end
