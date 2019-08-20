class MakeBookingsProfileDbsRequiredNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings_profiles, :dbs_required, :text, null: true
  end
end
