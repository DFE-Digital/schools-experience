# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      NAMESPACE = 'registration'.freeze

      def initialize(session)
        @registration_session = session[NAMESPACE] ||= {}
      end

      def save(model)
        @registration_session[model.model_name.param_key] =
          model.tap(&:flag_as_persisted!).attributes
      end

      # TODO add spec
      def email
        contact_information.email
      end

      def school
        subject_preference.school
      end

      def background_check
        fetch BackgroundCheck
      end

      # TODO add specs for these
      def contact_information
        fetch ContactInformation
      end

      def placement_preference
        fetch PlacementPreference
      end

      def subject_preference
        fetch SubjectPreference
      end

      def fetch(klass)
        klass.new @registration_session.fetch(klass.model_name.param_key)
      end

      def to_h
        { NAMESPACE => @registration_session }
      end

      def to_json
        to_h.to_json
      end

      def ==(other)
        # Ensure dates are compared correctly
        other.to_json == self.to_json
      end
    end
  end
end
