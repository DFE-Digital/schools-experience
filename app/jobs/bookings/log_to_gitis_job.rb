module Bookings
  class LogToGitisJob < ApplicationJob
    retry_on StandardError, wait: A_DECENT_AMOUNT_LONGER, attempts: 8

    def perform(contact_id, logline)
      gitis.log_school_experience \
        contact_id, logline
    end

  private

    def gitis_token
      Bookings::Gitis::Auth.new.token
    end

    def gitis
      Bookings::Gitis::CRM.new gitis_token
    end
  end
end
