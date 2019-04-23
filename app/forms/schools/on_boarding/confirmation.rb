module Schools
  module OnBoarding
    class Confirmation
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :acceptance, :boolean
      validates :acceptance, acceptance: true

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
