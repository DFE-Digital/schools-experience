class AddFeesWizardStateFieldsToSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :administration_fee_step_completed, :boolean, default: false
    add_column :schools_school_profiles, :dbs_fee_step_completed, :boolean, default: false
    add_column :schools_school_profiles, :other_fee_step_completed, :boolean, default: false
  end
end
