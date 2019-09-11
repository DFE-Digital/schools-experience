module Bookings
  class LogToGitisJob < GitisJob
    retry_on StandardError, wait: A_DECENT_AMOUNT_LONGER, attempts: 8

    def perform(contact_id, logline)
      gitis.log_school_experience \
        contact_id, logline
    end
  end
end
