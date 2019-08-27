module Bookings::Gitis
  class PrivacyPolicy
    include Entity

    self.entity_path = 'dfe_privacypolicies'

    entity_id_attribute :dfe_privacypolicyid
    entity_attribute :dfe_policyid
    entity_attribute :dfe_name
    entity_attribute :dfe_active

    def initialize(crm_data = {})
      crm_data = crm_data.stringify_keys

      self.dfe_privacypolicyid  = crm_data['dfe_privacypolicyid']
      self.dfe_policyid         = crm_data['dfe_policyid']
      self.dfe_name             = crm_data['dfe_name']
      self.dfe_active           = crm_data['dfe_active']

      super
    end
  end
end
