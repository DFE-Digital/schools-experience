# Wrapper around Rails session
# Namespaces registration sessions under the current school urn
module Candidates
  module Registrations
    class SchoolSession
      def initialize(urn, session)
        @school_session = session["schools/#{urn}/registrations"] ||= {}
        @school_session.merge! 'urn' => urn
      end

      def current_registration
        @current_registration ||= RegistrationSession.new @school_session
      end
    end
  end
end
