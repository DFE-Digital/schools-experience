class RemoveGitisUuidFromBookingsSubject < ActiveRecord::Migration[6.1]
  def change
    remove_column :bookings_subjects, :gitis_uuid, :uuid
  end
end
