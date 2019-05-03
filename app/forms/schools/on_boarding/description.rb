module Schools
  module OnBoarding
    class Description
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :details, :string

      validates :details, presence: true

      def self.compose(details)
        new details: details
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
