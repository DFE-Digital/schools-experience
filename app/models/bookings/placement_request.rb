# Persists the non personally identifiable information from a candidates
# registration
module Bookings
  class PlacementRequest < ApplicationRecord
    include Candidates::Registrations::Behaviours::PlacementPreference
    include Candidates::Registrations::Behaviours::SubjectPreference
    include Candidates::Registrations::Behaviours::BackgroundCheck

    def self.create_from_registration_session!(registration_session)
      self.create! \
        Candidates::Registrations::RegistrationAsPlacementRequest.new(registration_session).attributes
    end

    def school
      @school ||= Candidates::School.find urn
    end
  end
end
