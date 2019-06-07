class Bookings::CandidateSessionToken < ApplicationRecord
  AUTO_EXPIRE = 1.day.freeze

  belongs_to :candidate, class_name: 'Bookings::Candidate'
  has_secure_token

  scope :valid, -> do
    where(arel_table[:expired_at].gt(Time.zone.now)).
      or(where(expired_at: nil)).
      where(arel_table[:created_at].gt(AUTO_EXPIRE.ago))
  end

  def expired?
    expired_at? && expired_at <= Time.zone.now ||
      created_at? && created_at <= AUTO_EXPIRE.ago
  end

  def expire!
    return if expired_at?

    update(expired_at: Time.zone.now)
  end
end
