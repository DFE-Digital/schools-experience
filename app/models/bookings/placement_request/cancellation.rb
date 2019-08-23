class Bookings::PlacementRequest::Cancellation < ApplicationRecord
  belongs_to :placement_request,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: 'bookings_placement_request_id'

  validates :bookings_placement_request_id, uniqueness: true
  validates :reason, presence: true
  validates :cancelled_by, inclusion: %w(candidate school)
  validate :placement_request_not_closed, on: :create, if: :placement_request

  delegate \
    :school_email,
    :school_name,
    :school_urn,
    :candidate_email,
    :candidate_name,
    :contact_uuid,
    :dates_requested,
    :token,
    :booking,
    :placement_date,
    to: :placement_request

  def sent!
    update! sent_at: DateTime.now
  end

  def sent?
    sent_at.present?
  end

  def booking_date
    booking.date.to_formatted_s(:govuk)
  end

  def dates_requested
    if placement_request&.booking.present?
      placement_request.booking.date.to_formatted_s(:govuk)
    else
      placement_request.dates_requested
    end
  end

private

  def placement_request_not_closed
    if placement_request.closed?
      errors.add :placement_request, 'is already closed'
    end
  end
end
