class AddExperienceTypeToRequestsAndBookingsTables < ActiveRecord::Migration[6.1]
  def up
    add_column :bookings_placement_requests, :experience_type, :string
    add_column :bookings_bookings, :experience_type, :string

    migrate_data
  end

  def down
    remove_column :bookings_placement_requests, :experience_type
    remove_column :bookings_bookings, :experience_type
  end

  def migrate_data
    Bookings::PlacementRequest.find_each(batch_size: 100) do |pr|
      experience_type = pr.resolve_experience_type.downcase.delete(' ')

      pr.update_attribute('experience_type', experience_type)
    end

    # Skip the half finished booking records, as the Schools
    # will be asked to choose the experience type for these
    # ones when completing the acceptance form.
    Bookings::Booking.where('accepted_at IS NOT NULL').find_each(batch_size: 100) do |b|
      b.update(experience_type: b.bookings_placement_request.experience_type)
    end
  end
end
