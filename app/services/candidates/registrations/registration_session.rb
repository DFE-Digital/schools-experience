# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      class NotCompletedError < StandardError; end

      PENDING_EMAIL_CONFIRMATION_STATUS = 'pending_email_confirmation'.freeze
      COMPLETED_STATUS = 'completed'.freeze
      MIGRATE_ATTRS = %w{first_name last_name email}.freeze

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
        raise NotCompletedError unless all_steps_completed?

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

      def personal_information
        # Allow populating from pre Phase 3 data in the session
        param_key = PersonalInformation.model_name.param_key

        if !@registration_session[param_key].nil?
          return PersonalInformation.new @registration_session.fetch(param_key)
        end

        contact = @registration_session.fetch(ContactInformation.model_name.param_key)
        migrate = contact.slice(*MIGRATE_ATTRS)

        raise StepNotFound, param_key if migrate.empty?

        PersonalInformation.new(migrate).tap do |migrated|
          save migrated
        end
      rescue KeyError
        raise StepNotFound, param_key
      end

      def personal_information_attributes
        attrs = @registration_session.fetch(PersonalInformation.model_name.param_key, {})
        return attrs if attrs.any?

        # Allow populating with pre Phase 3 data in the session
        migrate = @registration_session.fetch(ContactInformation.model_name.param_key, {})
        migrate.slice(*MIGRATE_ATTRS)
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
          personal_information,
          placement_preference,
          subject_preference
        ].all?(&:valid?)
      rescue StepNotFound
        false
      end
    end
  end
end
