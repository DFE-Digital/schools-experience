module Schools
  module OnBoarding
    class CandidateRequirementsChoice < Step
      attribute :has_requirements, :boolean

      validates :has_requirements, inclusion: [true, false]

      def self.compose(has_requirements)
        new has_requirements: has_requirements
      end
    end
  end
end
