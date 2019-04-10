class CreateSchoolsSchoolProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :schools_school_profiles do |t|

      t.timestamps
      t.integer :urn, null: false
      t.string :candidate_requirement_dbs_requirement
      t.text :candidate_requirement_dbs_policy
      t.boolean :candidate_requirement_requirements
      t.text :candidate_requirement_requirements_details
    end
  end
end
