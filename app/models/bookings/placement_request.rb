# Persists the non personally identifiable information from a candidates
# registration
module Bookings
  class PlacementRequest < ApplicationRecord
    include Candidates::Registrations::Behaviours::PlacementPreference
    include Candidates::Registrations::Behaviours::SubjectPreference
    include Candidates::Registrations::Behaviours::BackgroundCheck

    has_secure_token

    belongs_to :school,
      class_name: 'Bookings::School',
      foreign_key: :bookings_school_id

    has_one :candidate_cancellation,
      -> { where cancelled_by: 'candidate' },
      class_name: 'Bookings::PlacementRequest::Cancellation',
      foreign_key: 'bookings_placement_request_id',
      dependent: :destroy

    def self.create_from_registration_session!(registration_session, analytics_tracking_uuid = nil)
      self.create! \
        Candidates::Registrations::RegistrationAsPlacementRequest
          .new(registration_session)
          .attributes
          .merge(analytics_tracking_uuid: analytics_tracking_uuid)
    end

    def sent_at
      created_at
    end

    def closed?
      cancelled? || completed?
    end

    # FIXME SE-1095 update this model to belong_to a candidate
    def candidate
      @candidate ||= Bookings::Gitis::CRM.new('abc123').find(1)
    end

  private

    def cancelled?
      candidate_cancellation.present?
    end

    def completed?
      # FIXME SE-1096 determine from booking
      false
    end
  end
end
