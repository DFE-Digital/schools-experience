module Schools
  module OnBoarding
    class AvailabilityDescription < Step
      attribute :description, :string
      validates :description, presence: true

      def self.compose(description)
        new description: description
      end
    end
  end
end
