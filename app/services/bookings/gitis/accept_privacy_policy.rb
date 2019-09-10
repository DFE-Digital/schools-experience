module Bookings
  module Gitis
    class AcceptPrivacyPolicy
      attr_reader :contact_id, :policy_id

      def initialize(crm, contact_id, policy_id)
        @crm = crm
        @contact_id = contact_id
        @policy_id = policy_id
      end

      def accept!
        match ? match.id : @crm.write(build)
      end

      def contact
        @contact ||= @crm.find(
          contact_id,
          includes: :dfe_contact_dfe_candidateprivacypolicy_Candidate
        )
      end

      def match
        @match ||= existing.find do |cpp|
          cpp._dfe_privacypolicynumber_value == policy_id
        end
      end

    private

      def build
        CandidatePrivacyPolicy.new \
          'dfe_name' => "Online consent as part of school experience registration",
          'dfe_consentreceivedby' => PrivacyPolicy.consent,
          'dfe_meanofconsent' => PrivacyPolicy.consent,
          'dfe_timeofconsent' => Time.now.utc.iso8601,
          '_dfe_candidate_value' => contact.id,
          '_dfe_privacypolicynumber_value' => @policy_id
      end

      def existing
        contact.dfe_contact_dfe_candidateprivacypolicy_Candidate || []
      end
    end
  end
end
