class AddRejectionCategoryToCancellations < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_request_cancellations, :rejection_category, :string, null: true

    add_index :bookings_placement_request_cancellations, :rejection_category, name: 'index_bookings_placement_request_cancellations_category'
  end
end
