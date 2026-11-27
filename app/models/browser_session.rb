# Server-side Rails session payload for ActionDispatch::Session::DatabaseStore.
# The browser only holds the random public session id; `session_id` here is its
# hashed form.
class BrowserSession < ApplicationRecord
  attribute :session_data, BrowserSession::PayloadType.new

  scope :live, -> { where(expires_at: Time.current..) }
  scope :expired, -> { where(expires_at: ...Time.current) }
end
