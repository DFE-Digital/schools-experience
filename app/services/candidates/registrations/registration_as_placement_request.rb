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
      ).freeze

      OTHER_IGNORED_ATTRS = %w(created_at updated_at).freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def attributes
        NON_PII_MODELS.inject({}) { |kept_attrs, model_name|
          kept_attrs.merge attributes_for(model_name)
        }.merge("bookings_school_id" => @registration_session.school.id)
      end

    private

      def attributes_for(model_name)
        @registration_session.public_send(model_name).attributes.reject do |k, _|
          OTHER_IGNORED_ATTRS.include? k
        end
      end
    end
  end
end
