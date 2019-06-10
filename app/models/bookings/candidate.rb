class Bookings::Candidate < ApplicationRecord
  UUID_V4_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/.freeze

  # delete_all used since there may be a lot of tokens, and the tokens don't have any real logic
  has_many :session_tokens, class_name: 'Candidates::SessionToken', dependent: :delete_all

  validates :gitis_uuid, presence: true, format: { with: UUID_V4_FORMAT }
  validates :gitis_uuid, uniqueness: { case_sensitive: false }

  def generate_session_token!
    session_tokens.create!
  end
end
