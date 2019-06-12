class Candidates::SessionToken < ApplicationRecord
  AUTO_EXPIRE = 1.day.freeze

  belongs_to :candidate, class_name: 'Bookings::Candidate'
  has_secure_token

  scope :unexpired, -> do
    where(arel_table[:expired_at].gt(Time.zone.now)).
      or(where(expired_at: nil))
  end

  scope :valid, -> do
    unexpired.where(arel_table[:created_at].gt(AUTO_EXPIRE.ago))
  end

  class << self
    def expire_all!
      unexpired.update_all(expired_at: Time.zone.now)
    end
  end

  def expired?
    expired_at? && expired_at <= Time.zone.now ||
      created_at? && created_at <= AUTO_EXPIRE.ago
  end

  def expire!
    return if expired_at? && expired_at <= Time.zone.now

    update!(expired_at: Time.zone.now)
  end

  def invalidate_other_tokens!
    candidate.session_tokens.unexpired.update_all(expired_at: Time.zone.now)
  end

  def to_param
    token
  end
end
