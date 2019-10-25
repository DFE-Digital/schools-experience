# Initialized with a RegistrationSession, `attributes` returns all the non
# personally identifiable attributes from the registration session in a format
# suitable for PlacementRequest.create.
module Candidates
  module Registrations
    class RegistrationAsPlacementRequest
      NON_PII_MODELS = %i(
        background_check
        placement_preference
        education
        teaching_preference
        subject_and_date_information
      ).freeze

      IGNORED_ATTRS = %w(created_at updated_at).freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def attributes
        non_pii_models.inject({}) { |kept_attrs, model_name|
          kept_attrs.merge attributes_for(model_name)
        }.merge("bookings_school_id" => school_id)
         .except("bookings_placement_dates_subject_id")
      end

    private

      def school_id
        @registration_session.school.id
      end

      def non_pii_models
        registration_state.steps & NON_PII_MODELS
      end

      def registration_state
        @registration_state ||= RegistrationState.new @registration_session
      end

      def attributes_for(model_name)
        @registration_session
          .public_send(model_name)
          .attributes
          .except(*IGNORED_ATTRS)
      end
    end
  end
end
