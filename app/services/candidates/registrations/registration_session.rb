# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      class NotCompletedError < StandardError; end

      PENDING_EMAIL_CONFIRMATION_STATUS = 'pending_email_confirmation'.freeze
      COMPLETED_STATUS = 'completed'.freeze

      def initialize(session)
        @registration_session = session
      end

      def save(model)
        @registration_session[model.model_name.param_key] =
          model.tap(&:flag_as_persisted!).attributes
      end

      def uuid
        @registration_session['uuid'] ||= SecureRandom.urlsafe_base64
      end

      def flag_as_pending_email_confirmation!
        raise NotCompletedError unless all_steps_completed?

        @registration_session['status'] = PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def pending_email_confirmation?
        @registration_session['status'] == PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def flag_as_completed!
        @registration_session['status'] = COMPLETED_STATUS
      end

      def completed?
        @registration_session['status'] == COMPLETED_STATUS
      end

      # TODO add spec
      def email
        contact_information.email
      end

      def urn
        @registration_session.fetch 'urn'
      end

      def school
        @school ||= Candidates::School.find urn
      end

      def school_name
        school.name
      end

      def background_check
        fetch BackgroundCheck
      end

      def background_check_attributes
        fetch_attributes BackgroundCheck
      end

      # TODO add specs for these
      def contact_information
        fetch ContactInformation
      end

      def contact_information_attributes
        fetch_attributes ContactInformation
      end

      def placement_preference
        fetch PlacementPreference
      end

      def placement_preference_attributes
        fetch_attributes PlacementPreference
      end

      def subject_preference
        fetch SubjectPreference
      end

      def subject_preference_attributes
        fetch_attributes SubjectPreference
      end

      def fetch(klass)
        klass.new @registration_session.fetch(klass.model_name.param_key)
      rescue KeyError => e
        raise StepNotFound, e.key
      end

      def fetch_attributes(klass)
        @registration_session.fetch(klass.model_name.param_key, {})
      end

      def to_h
        @registration_session
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      def ==(other)
        # Ensure dates are compared correctly
        other.to_json == self.to_json
      end

    private

      def all_steps_completed?
        [
          background_check,
          contact_information,
          placement_preference,
          subject_preference
        ].all?(&:valid?)
      rescue StepNotFound
        false
      end
    end
  end
end
