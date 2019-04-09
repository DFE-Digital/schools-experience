class AddFeesToSchoolsSchoolProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :schools_school_profiles, :fees_administration_fees, :boolean
    add_column :schools_school_profiles, :fees_dbs_fees, :boolean
    add_column :schools_school_profiles, :fees_other_fees, :boolean
  end
end
