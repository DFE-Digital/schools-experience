class AddDbsRequirementColumnsToSchoolsOnBoardingProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :dbs_requirement_requires_check, :boolean
    add_column :schools_school_profiles, :dbs_requirement_dbs_policy_details, :text
    add_column :schools_school_profiles, :dbs_requirement_no_dbs_policy_details, :text
  end
end
