class GitisJob < ApplicationJob
  delegate :gitis, to: Bookings::Gitis::Factory
end
