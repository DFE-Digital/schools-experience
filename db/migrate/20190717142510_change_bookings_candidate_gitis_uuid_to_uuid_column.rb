class ChangeBookingsCandidateGitisUuidToUuidColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :bookings_candidates, :gitis_uuid, 'uuid USING CAST(gitis_uuid AS uuid)'
  end

  def down
    change_column :bookings_candidates, :gitis_uuid, 'varchar(36) USING CAST(gitis_uuid AS varchar)'
  end
end
