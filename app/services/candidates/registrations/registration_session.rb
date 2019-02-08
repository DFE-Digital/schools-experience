# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      def initialize(session)
        @registration_session = session['registration'] ||= {}
      end

      def save(model)
        @registration_session[model.model_name.param_key] =
          model.tap(&:persisted!).attributes
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

      def fetch(klass)
        klass.new @registration_session.fetch(klass.model_name.param_key)
      end
    end
  end
end
