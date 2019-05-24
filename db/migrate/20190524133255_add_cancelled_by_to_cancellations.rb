class AddCancelledByToCancellations < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_request_cancellations, :cancelled_by, :string, null: false
  end
end
