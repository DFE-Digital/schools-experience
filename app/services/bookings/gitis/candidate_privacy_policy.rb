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

    def initialize(crm_data = {})
      crm_data = crm_data.stringify_keys

      self.dfe_candidateprivacypolicyid = crm_data['dfe_candidateprivacypolicyid']
      self.dfe_name                     = crm_data['dfe_name']
      self.dfe_consentreceivedby        = crm_data['dfe_consentreceivedby']
      self.dfe_meanofconsent            = crm_data['dfe_meanofconsent']
      self.dfe_timeofconsent            = crm_data['dfe_timeofconsent']

      self.dfe_Candidate                = crm_data['_dfe_candidate_value']
      self.dfe_PrivacyPolicyNumber      = crm_data['_dfe_privacypolicynumber_value']

      super
    end
  end
end
