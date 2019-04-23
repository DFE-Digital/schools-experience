module Schools
  module OnBoarding
    class AvailabilityPreference
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :fixed, :boolean
      validates :fixed, inclusion: [true, false]

      def self.compose(fixed)
        new fixed: fixed
      end

      def fixed?
        fixed
      end

      def flexible?
        !fixed?
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
