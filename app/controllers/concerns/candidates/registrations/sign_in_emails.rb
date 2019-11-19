module Candidates
  module Registrations
    module SignInEmails
      extend ActiveSupport::Concern

    private

      def verification_email(token)
        NotifyEmail::CandidateVerifyEmailLink.new(
          to: current_registration.personal_information.email,
          verification_link: verification_link(token)
        )
      end

      def verification_link(token)
        candidates_registration_verify_url \
          current_registration.urn,
          token,
          current_registration.uuid,
          host: request.host
      end
    end
  end
end
