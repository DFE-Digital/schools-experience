module Schools
  module OnBoarding
    class ExperienceOutline < Step
      attribute :candidate_experience, :string

      # We want to allow blank values so school admins aren't forced to complete
      # the step, but we need a validation so steps aren't valid when initialised
      # as CurrentStep uses valid? to determine if a step has been completed.
      validates :candidate_experience, \
        length: { minimum: 0, allow_nil: false, message: "can't be nil" }

      def self.compose(candidate_experience)
        new candidate_experience: candidate_experience
      end
    end
  end
end
