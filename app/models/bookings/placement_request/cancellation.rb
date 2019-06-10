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
    :school_admin_name,
    :dates_requested,
    :candidate_email,
    :candidate_name,
    :requested_availability,
    to: :placement_request

  def requested_availability
    placement_request.availability
  end

  def sent!
    update! sent_at: DateTime.now
  end

  def sent?
    sent_at.present?
  end

private

  def placement_request_not_closed
    if placement_request.closed?
      errors.add :placement_request, 'is already closed'
    end
  end
end
