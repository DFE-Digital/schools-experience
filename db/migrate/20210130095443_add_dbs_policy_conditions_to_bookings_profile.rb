class AddDbsPolicyConditionsToBookingsProfile < ActiveRecord::Migration[6.1]
  def up
    add_column :bookings_profiles, :dbs_policy_conditions, :string

    execute <<~EOSQL
      UPDATE
        bookings_profiles
      SET
        dbs_policy_conditions=(CASE dbs_requires_check WHEN 't' THEN 'required' ELSE 'notrequired' END)
      WHERE
        dbs_requires_check IS NOT NULL
    EOSQL

    add_column :schools_school_profiles, :dbs_requirement_dbs_policy_conditions, :string
    add_column :schools_school_profiles, :dbs_requirement_dbs_policy_details_inschool, :text
  end

  def down
    remove_column :schools_school_profiles, :dbs_requirement_dbs_policy_details_inschool
    remove_column :schools_school_profiles, :dbs_requirement_dbs_policy_conditions
    remove_column :bookings_profiles, :dbs_policy_conditions
  end
end
