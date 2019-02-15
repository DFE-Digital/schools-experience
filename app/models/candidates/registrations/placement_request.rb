# Persists the non personally identifiable information from a candidates
# registration
module Candidates
  module Registrations
    class PlacementRequest < ApplicationRecord
      include Behaviours::PlacementPreference
      include Behaviours::SubjectPreference
      include Behaviours::BackgroundCheck

      def self.create_from_registration_session!(registration_session)
        self.create! \
          RegistrationAsPlacementRequest.new(registration_session).attributes
      end
    end
  end
end
