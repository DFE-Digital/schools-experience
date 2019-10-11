module Candidates
  module Registrations
    class RegistrationState
      REQUIRED_STEPS = %i(
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
        background_check
      ).freeze

      # These steps will only be shown when the school has fixed dates
      # and will be the first pages (currently only one) of the wizard
      OPTIONAL_INITIAL_STEPS = %i(subject_and_date_information).freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def steps
        if @registration_session.school.availability_preference_fixed?
          [OPTIONAL_INITIAL_STEPS, REQUIRED_STEPS].flatten
        else
          REQUIRED_STEPS
        end
      end

      def next_step
        steps.detect(&method(:step_not_completed?)) || :COMPLETED
      end

      def completed?
        next_step == :COMPLETED
      end

      def step_completed?(wizard_step)
        @registration_session.public_send(wizard_step).valid?
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
