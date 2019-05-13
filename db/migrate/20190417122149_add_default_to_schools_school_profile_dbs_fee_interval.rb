class AddDefaultToSchoolsSchoolProfileDbsFeeInterval < ActiveRecord::Migration[5.2]
  def change
    change_column_default :schools_school_profiles, :dbs_fee_interval, from: nil, to: 'One-off'
  end
end
