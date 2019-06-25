module Candidates
  module Registrations
    class PrivacyPolicy
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :acceptance, :boolean

      validates :acceptance, acceptance: true

      alias_method :accepted?, :valid?

      def not_accepted?
        !accepted?
      end
    end
  end
end
