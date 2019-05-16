class Bookings::PlacementRequest::Cancellation < ApplicationRecord
  belongs_to :placement_request,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: 'bookings_placement_request_id'

  validates :bookings_placement_request_id, uniqueness: true
  validates :reason, presence: true
end
