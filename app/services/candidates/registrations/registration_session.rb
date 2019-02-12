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
      def account_check
        fetch AccountCheck
      end

      def address
        fetch Address
      end

      def background_check
        fetch BackgroundCheck
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

      def ==(other)
        other.to_h == self.to_h
      end
    end
  end
end
