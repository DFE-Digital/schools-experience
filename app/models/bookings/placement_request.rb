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

    has_one :booking,
      class_name: 'Bookings::Booking',
      foreign_key: 'bookings_placement_request_id'

    belongs_to :placement_date,
      class_name: 'Bookings::PlacementDate',
      foreign_key: :bookings_placement_date_id,
      optional: true

    has_one :candidate_cancellation,
      -> { where cancelled_by: 'candidate' },
      class_name: 'Bookings::PlacementRequest::Cancellation',
      foreign_key: 'bookings_placement_request_id',
      dependent: :destroy

    has_one :school_cancellation,
      -> { where cancelled_by: 'school' },
      class_name: 'Bookings::PlacementRequest::Cancellation',
      foreign_key: 'bookings_placement_request_id',
      dependent: :destroy

    scope :open, -> do
      left_joins(:candidate_cancellation, :school_cancellation)
        .where(bookings_placement_request_cancellations: { sent_at: nil })
        .where(school_cancellations_bookings_placement_requests: { sent_at: nil })
    end

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

    def open?
      !closed?
    end

    def viewed!
      if viewed_at.nil?
        update(viewed_at: Time.now)
      end
    end

    # FIXME SE-1095 update this model to belong_to a candidate
    def candidate
      @candidate ||= Bookings::Gitis::CRM.new('abc123').find(1)
    end

    def dates_requested
      if placement_date.present?
        placement_date.date.to_formatted_s(:govuk)
      else
        availability
      end
    end

    def received_on
      created_at.to_date.to_formatted_s(:govuk)
    end

    # FIXME SE-1130
    def status
      return 'Cancelled' if cancelled?

      'New'
    end

    def dbs
      if has_dbs_check?
        'Yes'
      else
        'No'
      end
    end

    def teaching_subjects
      [subject_first_choice, subject_second_choice]
    end

    def school_email
      school.notifications_email
    end

    def school_name
      school.name
    end

    def school_admin_name
      school.admin_contact_name
    end

    def candidate_email
      candidate.email
    end

    def candidate_name
      candidate.full_name
    end

  private

    def cancelled?
      candidate_cancellation&.sent? || school_cancellation&.sent?
    end

    def completed?
      # FIXME SE-1096 determine from booking
      false
    end
  end
end
