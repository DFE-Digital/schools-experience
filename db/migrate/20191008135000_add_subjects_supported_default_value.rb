class AddSubjectsSupportedDefaultValue < ActiveRecord::Migration[5.2]
  def up
    change_column :bookings_placement_dates, :supports_subjects, :boolean, null: false, default: true
  end

  def down
    change_column :bookings_placement_dates, :supports_subjects, :boolean
  end
end
