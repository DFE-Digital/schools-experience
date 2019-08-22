module Bookings
  class LogToGitisJob < ApplicationJob
    retry_on StandardError, wait: A_DECENT_AMOUNT_LONGER, attempts: 8

    def perform(contact_id, recorded, action, se_date, urn, schoolname)
      gitis.log_school_experience \
        contact_id, recorded, action, se_date, urn, schoolname
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
