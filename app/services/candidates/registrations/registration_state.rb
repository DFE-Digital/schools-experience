module Candidates
  module Registrations
    class RegistrationState
      STEPS = %i[
        subject_and_date_information
        personal_information
        contact_information
        education
        teaching_preference
        placement_preference
        background_check
      ].freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def next_step
        steps.detect(&method(:step_not_completed?)) || :COMPLETED
      end

      def steps
        STEPS.select(&method(:step_in_journey?))
      end

      def completed?
        next_step == :COMPLETED
      end

      def step_completed?(wizard_step)
        @registration_session.public_send(wizard_step).completed?
      rescue RegistrationSession::StepNotFound
        false
      end

      def step_not_completed?(step)
        !step_completed? step
      end

      def step_in_journey?(step)
        send "#{step}_in_journey?"
      end

      # Override these methods to add branching based on the session.
      STEPS.each do |step|
        define_method "#{step}_in_journey?" do
          true
        end
      end

      def subject_and_date_information_in_journey?
        @registration_session.school.availability_preference_fixed?
      end
    end
  end
end
