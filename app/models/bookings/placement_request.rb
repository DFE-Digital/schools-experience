# Persists the non personally identifiable information from a candidates
# registration
module Bookings
  class PlacementRequest < ApplicationRecord
    include Candidates::Registrations::Behaviours::PlacementPreference
    include Candidates::Registrations::Behaviours::SubjectPreference
    include Candidates::Registrations::Behaviours::BackgroundCheck

    belongs_to :school,
      class_name: 'Bookings::School',
      foreign_key: :bookings_school_id

    has_one :booking,
      class_name: 'Bookings::Booking',
      foreign_key: 'bookings_placement_request_id'

    belongs_to :placement_date,
      class_name: 'Bookings::PlacementDate',
      foreign_key: :bookings_placement_date_id,
      optional: true

    def self.create_from_registration_session!(registration_session, analytics_tracking_uuid = nil)
      self.create! \
        Candidates::Registrations::RegistrationAsPlacementRequest
          .new(registration_session)
          .attributes
          .merge(analytics_tracking_uuid: analytics_tracking_uuid)
    end

    # FIXME this will eventually be handled 'higher up', probably by
    # a helper or directly in the view
    def candidate
      Bookings::Gitis::CRM.new('abc123').find(1)
    end
  end
end
