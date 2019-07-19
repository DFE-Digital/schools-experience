module Candidates
  module Registrations
    class RegistrationState
      STEPS = %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
        background_check
      ).freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def steps
        STEPS
      end

      def next_step
        steps.detect(&method(:step_not_completed?)) || :COMPLETED
      end

      def completed?
        next_step == :COMPLETED
      end

      def step_completed?(step)
        @registration_session.public_send(step).valid?
      rescue RegistrationSession::StepNotFound
        false
      end

    private

      def step_not_completed?(step)
        !step_completed? step
      end
    end
  end
end
