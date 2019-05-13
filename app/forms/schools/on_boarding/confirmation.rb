module Schools
  module OnBoarding
    class Confirmation < Step
      attribute :acceptance, :boolean
      validates :acceptance, acceptance: true
      def self.compose(acceptance)
        new acceptance: acceptance
      end
    end
  end
end
