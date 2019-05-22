class Bookings::PlacementRequest::Cancellation < ApplicationRecord
  belongs_to :placement_request,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: 'bookings_placement_request_id'

  validates :bookings_placement_request_id, uniqueness: true
  validates :reason, presence: true

  def school_email
    placement_request.school.contact_email
  end

  def school_name
    placement_request.school.name
  end

  def school_admin_name
    placement_request.school.admin_contact_name
  end

  def candidate_email
    placement_request.candidate.email
  end

  def candidate_name
    placement_request.candidate.full_name
  end

  def requested_availability
    placement_request.availability
  end
end
