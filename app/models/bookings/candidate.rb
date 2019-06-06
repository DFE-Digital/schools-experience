class Bookings::Candidate < ApplicationRecord
  UUID_V4_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

  validates :gitis_uuid, presence: true, format: { with: UUID_V4_FORMAT }
  validates :gitis_uuid, uniqueness: { case_sensitive: false }
end
