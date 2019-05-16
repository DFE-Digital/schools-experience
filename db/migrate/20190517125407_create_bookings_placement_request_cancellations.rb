class CreateBookingsPlacementRequestCancellations < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings_placement_request_cancellations do |t|
      t.belongs_to :bookings_placement_request, foreign_key: true, index: { name: 'index_cancellations_on_bookings_placement_request_id' }
      t.text :reason, null: false

      t.timestamps
    end
  end
end
