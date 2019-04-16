module Schools
  module OnBoarding
    class AvailabilityDescription
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :description, :string
      validates :description, presence: true

      def self.compose(description)
        new description: description
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
