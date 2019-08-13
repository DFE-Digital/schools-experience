# Wrapper around Rails session
# Namespaces registration sessions under the current school urn
module Candidates
  module Registrations
    class SchoolSession
      class << self
        def delete_all_registrations(session)
          session.keys.grep(%r{\Aschools/[^/]+/registrations\z}).each do |key|
            session.delete key
          end
        end
      end

      def initialize(urn, session)
        @school_session = session["schools/#{urn}/registrations"] ||= {}
        @school_session.merge! 'urn' => urn
      end

      def current_registration
        @current_registration ||= RegistrationSession.new @school_session
      end

      def gitis_registration(current_contact)
        @gitis_registration ||= GitisRegistrationSession.new @school_session, current_contact
      end
    end
  end
end
