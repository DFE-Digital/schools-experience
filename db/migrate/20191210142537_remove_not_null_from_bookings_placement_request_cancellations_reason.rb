class RemoveNotNullFromBookingsPlacementRequestCancellationsReason < ActiveRecord::Migration[5.2]
  def up
    change_column :bookings_placement_request_cancellations, :reason, :text, null: true
  end

  def down
    change_column :bookings_placement_request_cancellations, :reason, :text, null: false
  end
end
