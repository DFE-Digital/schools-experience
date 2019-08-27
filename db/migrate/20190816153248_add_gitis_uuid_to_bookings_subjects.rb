class AddGitisUuidToBookingsSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_subjects, :gitis_uuid, :uuid
    add_index :bookings_subjects, :gitis_uuid, unique: true
  end
end
