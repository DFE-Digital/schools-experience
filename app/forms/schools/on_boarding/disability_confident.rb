module Schools
  module OnBoarding
    class DisabilityConfident < Step
      attribute :is_disability_confident, :boolean

      validates :is_disability_confident, inclusion: [true, false]

      def self.compose(is_disability_confident)
        new is_disability_confident: is_disability_confident
      end
    end
  end
end
