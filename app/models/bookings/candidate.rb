class Bookings::Candidate < ApplicationRecord
  UUID_V4_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

  # delete_all used since there may be a lot of tokens, and the tokens don't have any real logic
  has_many :session_tokens, class_name: 'Candidates::SessionToken', dependent: :delete_all
  has_many :placement_requests, class_name: 'Bookings::PlacementRequest', dependent: :destroy
  has_many :bookings, through: :placement_requests

  validates :gitis_uuid, presence: true, format: { with: UUID_V4_FORMAT }
  validates :gitis_uuid, uniqueness: { case_sensitive: false }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  def generate_session_token!
    session_tokens.create!
  end

  def expire_session_tokens!
    session_tokens.expire_all!
  end

  def confirmed?
    confirmed_at?
  end

  def last_signed_in_at
    confirmed_at || session_tokens.confirmed.maximum(:confirmed_at)
  end
end
