class AddBookingsPlacementDatesSubjectIdToBookingsPlacementRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings_placement_requests, :bookings_placement_dates_subject_id, :integer

    add_index :bookings_placement_requests, :bookings_placement_dates_subject_id, name: :index_bookings_placement_requests_dates_subject_id

    add_foreign_key :bookings_placement_requests, :bookings_placement_date_subjects, column: :bookings_placement_dates_subject_id, name: :bookings_placement_requests_date_subject_id
  end
end
