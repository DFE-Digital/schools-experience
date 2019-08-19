module Candidates
  module Registrations
    class SendEmailConfirmationJob < ApplicationJob
      queue_as :default

      def perform(uuid, host)
        registration_session = RegistrationStore.instance.retrieve! uuid

        notification = NotifyEmail::CandidateMagicLink.new \
          to: registration_session.email,
          school_name: registration_session.school.name,
          confirmation_link: confirmation_link(uuid, host)

        notification.despatch_later!
      end

    private

      def confirmation_link(uuid, host)
        Rails.application.routes.url_helpers.candidates_confirm_url \
          uuid: uuid,
          host: host
      end
    end
  end
end
