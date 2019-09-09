module Schools
  module OnBoarding
    class CandidateRequirement < Step
      attribute :requirements, :boolean
      attribute :requirements_details, :string

      validates :requirements, inclusion: [true, false]
      validates :requirements_details, presence: true, if: :requirements

      def self.compose(requirements, requirements_details)
        new \
          requirements: requirements,
          requirements_details: requirements_details
      end
    end
  end
end
