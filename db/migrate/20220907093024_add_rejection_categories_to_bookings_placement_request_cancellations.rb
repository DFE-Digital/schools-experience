class AddRejectionCategoriesToBookingsPlacementRequestCancellations < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings_placement_request_cancellations, :fully_booked, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :accepted_on_ttc, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :date_not_available, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :no_relevant_degree, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :no_phase_availability, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :candidate_not_local, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :duplicate, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :info_not_provided, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :cancelation_requested, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :wrong_choice_secondary, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :wrong_choice_primary, :boolean, default: false
    add_column :bookings_placement_request_cancellations, :other, :boolean, default: false

    Bookings::PlacementRequest::Cancellation.where.not(rejection_category: nil).find_in_batches do |cancellations|
      cancellations.each do |cancellation|
        cancellation.update(cancellation.rejection_category => true)
      end
    end
  end
end
