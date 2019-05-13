class AddKeyStageListToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :key_stage_list_early_years, :boolean, default: false
    add_column :schools_school_profiles, :key_stage_list_key_stage_1, :boolean, default: false
    add_column :schools_school_profiles, :key_stage_list_key_stage_2, :boolean, default: false
  end
end
