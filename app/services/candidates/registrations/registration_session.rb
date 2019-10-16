# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      class NotCompletedError < StandardError; end
      class StepNotFound < StandardError; end

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
        personal_information.email
      end

      def urn
        @registration_session.fetch 'urn'
      end

      def school
        @school ||= Candidates::School.find urn if urn.present?
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

      def subject_and_date_information
        fetch SubjectAndDateInformation
      end

      def subject_and_date_information_attributes
        fetch_attributes SubjectAndDateInformation
      end

      # TODO add specs for these
      def contact_information
        fetch ContactInformation
      end

      def contact_information_attributes
        fetch_attributes ContactInformation
      end

      def personal_information
        fetch PersonalInformation
      end

      def personal_information_attributes
        fetch_attributes PersonalInformation
      end

      def placement_preference
        fetch PlacementPreference
      end

      def placement_preference_attributes
        fetch_attributes PlacementPreference
      end

      def education_attributes
        fetch_attributes Education
      end

      def education
        fetch Education
      end

      def teaching_preference_attributes
        fetch_attributes TeachingPreference
      end

      def teaching_preference
        fetch(TeachingPreference).tap { |tp| tp.school = school }
      end

      def fetch(klass)
        klass.new(@registration_session.fetch(klass.model_name.param_key)).tap { |model| model.urn = self.urn }
      rescue KeyError => e
        raise StepNotFound, e.key
      end

      def fetch_attributes(klass, defaults = {})
        @registration_session.fetch(klass.model_name.param_key, defaults)
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
        RegistrationState.new(self).completed?
      end
    end
  end
end
