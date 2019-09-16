module Bookings::Gitis
  class PrivacyPolicy
    include Entity

    self.entity_path = 'dfe_privacypolicies'

    entity_id_attribute :dfe_privacypolicyid
    entity_attribute :dfe_policyid
    entity_attribute :dfe_name
    entity_attribute :dfe_active

    class << self
      def default
        Rails.application.config.x.gitis.privacy_policy_id
      end

      def consent
        Rails.application.config.x.gitis.privacy_consent_id
      end
    end
  end
end
