# Server-side Rails session payload for ActionDispatch::Session::DatabaseStore.
# The browser only holds the random public session id; `session_id` here is its
# hashed form.
class BrowserSession < ApplicationRecord
  scope :live, -> { where(expires_at: Time.current..) }
  scope :expired, -> { where(expires_at: ...Time.current) }

  def self.dump(payload)
    Marshal.dump(payload)
  end

  # Marshal keeps Dates, symbols and nested hashes exactly as the previous
  # cache-backed store did. The column is only ever written by this application
  # (and is excluded from analytics), the same trust as the cache it replaces.
  def payload
    Marshal.load(session_data) # rubocop:disable Security/MarshalLoad
  end
end
