module Schools
  module OnBoarding
    class Description
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :details, :string

      # We want to allow blank values so school admins aren't forced to complete
      # the step, but we need a validation so steps aren't valid when initialised
      # as CurrentStep uses valid? to determine if a step has been completed.
      validates :details, \
        length: { minimum: 0, allow_nil: false, message: "can't be nil" }

      def self.compose(details)
        new details: details
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
