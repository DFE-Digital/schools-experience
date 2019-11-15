# Handles mapping the user's browser session to the registration data stored in
# redis.
module Candidates
  module Registrations
    module CurrentRegistration
      extend ActiveSupport::Concern

      def current_registration
        @current_registration ||= get_current_registration
      end

      def persist(model)
        current_registration.save model
        store.store! current_registration
        self.current_registration_session_uuid = current_registration.uuid
      end

    private

      def get_current_registration
        if current_contact
          Candidates::Registrations::GitisRegistrationSession.new \
            registration_session_attributes, current_contact
        else
          Candidates::Registrations::RegistrationSession.new \
            registration_session_attributes
        end
      end

      def registration_session_attributes
        if store.has_registration?(current_registration_session_uuid)
          store.retrieve!(current_registration_session_uuid).to_h
        elsif session.has_key? "schools/#{current_urn}/registrations"
          # TODO SE-1992 Remove this
          # Get attributes from legacy session
          session["schools/#{current_urn}/registrations"]
        else
          # Start a new registration_session
          { 'urn' => current_urn }
        end
      end

      def store
        Candidates::Registrations::RegistrationStore.instance
      end

      def candidates_registrations
        session[:registrations] ||= {}
      end

      # We need to namespace each registration by school to avoid overwriting
      # data if the candidate is applying for multiple schools in seperate
      # tabs.
      def current_registration_session_uuid
        candidates_registrations[current_urn]
      end

      # Changing the current_registration_session_uuid will point the user's
      # browser session at a different registration_session.
      def current_registration_session_uuid=(uuid)
        candidates_registrations[current_urn] = uuid
      end

      def current_urn
        params[:school_id]
      end
    end
  end
end
