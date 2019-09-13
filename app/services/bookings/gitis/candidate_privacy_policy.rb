module Bookings::Gitis
  class CandidatePrivacyPolicy
    include Entity

    self.entity_path = 'dfe_candidateprivacypolicies'

    entity_id_attribute :dfe_candidateprivacypolicyid
    entity_attribute :dfe_name
    entity_attribute :dfe_consentreceivedby
    entity_attribute :dfe_meanofconsent
    entity_attribute :dfe_timeofconsent

    entity_association :dfe_Candidate, Contact
    entity_association :dfe_PrivacyPolicyNumber, PrivacyPolicy
  end
end
