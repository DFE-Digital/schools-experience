class AddIndexToSchoolsSchoolProfileUrn < ActiveRecord::Migration[5.2]
  def change
    add_index :schools_school_profiles, :urn
  end
end
