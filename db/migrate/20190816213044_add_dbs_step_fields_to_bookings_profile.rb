class AddDbsStepFieldsToBookingsProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_profiles, :dbs_requires_check, :boolean
    add_column :bookings_profiles, :dbs_policy_details, :text
  end
end
