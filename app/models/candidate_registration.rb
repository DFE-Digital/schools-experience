# Unfinished candidate registration, keyed by the registration's UUID. Backs
# Candidates::Registrations::RegistrationStore. Reads must go through `.live`
# so expiry is enforced even when cleanup has not run.
class CandidateRegistration < ApplicationRecord
  scope :live, -> { where(expires_at: Time.current..) }
  scope :expired, -> { where(expires_at: ...Time.current) }
end
