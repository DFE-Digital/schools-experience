module Schools
  module OnBoarding
    class AvailabilityPreference < Step
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
    end
  end
end
