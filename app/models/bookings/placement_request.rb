# Persists the non personally identifiable information from a candidates
# registration
module Bookings
  class PlacementRequest < ApplicationRecord
    attr_accessor :gitis_contact
    include Candidates::Registrations::Behaviours::PlacementPreference
    include Candidates::Registrations::Behaviours::SubjectPreference
    include Candidates::Registrations::Behaviours::BackgroundCheck

    has_secure_token

    belongs_to :school,
      class_name: 'Bookings::School',
      foreign_key: :bookings_school_id

    belongs_to :candidate,
      class_name: 'Bookings::Candidate',
      foreign_key: :candidate_id,
      optional: true

    has_one :booking,
      class_name: 'Bookings::Booking',
      foreign_key: 'bookings_placement_request_id',
      inverse_of: :bookings_placement_request

    belongs_to :placement_date,
      class_name: 'Bookings::PlacementDate',
      foreign_key: :bookings_placement_date_id,
      optional: true

    has_one :candidate_cancellation,
      -> { where cancelled_by: 'candidate' },
      class_name: 'Bookings::PlacementRequest::Cancellation',
      foreign_key: 'bookings_placement_request_id',
      inverse_of: :placement_request,
      dependent: :destroy

    has_one :school_cancellation,
      -> { where cancelled_by: 'school' },
      class_name: 'Bookings::PlacementRequest::Cancellation',
      foreign_key: 'bookings_placement_request_id',
      inverse_of: :placement_request,
      dependent: :destroy

    scope :open, -> do
      left_joins(:candidate_cancellation, :school_cancellation, :booking)
        .where(bookings_placement_request_cancellations: { sent_at: nil })
        .where(school_cancellations_bookings_placement_requests: { sent_at: nil })
        .where(bookings_bookings: { bookings_placement_request_id: nil })
    end

    def self.create_from_registration_session!(registration_session, analytics_tracking_uuid = nil, context: nil)
      self.new(
        Candidates::Registrations::RegistrationAsPlacementRequest
          .new(registration_session)
          .attributes
          .merge(analytics_tracking_uuid: analytics_tracking_uuid)
      ).tap { |r| r.save!(context: context) }
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

    def contact_uuid
      1
    end

    def dates_requested
      if placement_date.present?
        placement_date.date.to_formatted_s(:govuk)
      else
        availability
      end
    end

    def received_on
      created_at.to_date
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
      gitis_contact.email
    end

    def candidate_name
      gitis_contact.full_name
    end

    def cancellation
      candidate_cancellation || school_cancellation
    end

    def fetch_gitis_contact(crm)
      self.gitis_contact = crm.find(contact_uuid)
    end

  private

    def cancelled?
      cancellation&.sent?
    end

    def completed?
      # FIXME SE-1096 determine from booking
      false
    end
  end
end
