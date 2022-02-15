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
      experience_type = pr.resolve_experience_type

      # rubocop:disable Rails/SkipsModelValidations
      pr.update_attribute('experience_type', experience_type)
      # rubocop:enable Rails/SkipsModelValidations
    end

    # Skip the booking records that can't determine the experience
    # type. The Schools will be asked to choose one when completing
    # the acceptance form.
    Bookings::Booking.find_each(batch_size: 100) do |b|
      placement_request = b.bookings_placement_request

      unless placement_request.unclear_experience_type?
        b.update(experience_type: placement_request.experience_type)
      end
    end
  end
end
