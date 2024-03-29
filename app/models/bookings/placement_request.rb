# Persists the non personally identifiable information from a candidates
# registration
module Bookings
  class PlacementRequest < ApplicationRecord
    include ViewTrackable
    include Candidates::Registrations::Behaviours::PlacementPreference
    include Candidates::Registrations::Behaviours::AvailabilityPreference
    include Candidates::Registrations::Behaviours::Education
    include Candidates::Registrations::Behaviours::TeachingPreference
    include Candidates::Registrations::Behaviours::BackgroundCheck
    include Candidates::Registrations::Behaviours::SubjectAndDateInformation

    has_secure_token

    EXPERIENCE_TYPES = %w[inschool virtual].freeze

    validates :candidate, presence: { unless: :pre_phase3_record? }

    validates :subject, presence: true,
                        if: -> { placement_date&.subject_specific? },
                        unless: :creating_placement_request_from_registration_session?

    validates :experience_type, presence: true

    belongs_to :school,
      class_name: 'Bookings::School',
      inverse_of: :placement_requests,
      foreign_key: :bookings_school_id

    belongs_to :candidate,
      class_name: 'Bookings::Candidate',
      inverse_of: :placement_requests,
      foreign_key: :candidate_id,
      optional: true

    has_one :booking,
      class_name: 'Bookings::Booking',
      foreign_key: 'bookings_placement_request_id',
      inverse_of: :bookings_placement_request,
      dependent: :destroy

    belongs_to :placement_date,
      class_name: 'Bookings::PlacementDate',
      foreign_key: :bookings_placement_date_id,
      inverse_of: :placement_requests,
      optional: true # If this is a placement_request to a school with fixed dates

    belongs_to :subject,
      class_name: 'Bookings::Subject',
      foreign_key: :bookings_subject_id,
      inverse_of: :placement_requests,
      optional: true # If this is a placement_request for a subject_specific_date

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

    scope :unprocessed, lambda {
      not_cancelled.merge unbooked
    }

    scope :unbooked, lambda {
      without_booking.or booking_not_sent
    }

    scope :booking_not_sent, lambda {
      left_joins(:booking).where(bookings_bookings: { accepted_at: nil })
    }

    scope :without_booking, lambda {
      left_joins(:booking)
        .where(bookings_bookings: { bookings_placement_request_id: nil })
    }

    scope :cancelled, lambda {
      left_joins(:candidate_cancellation, :school_cancellation)
        .where <<~SQL
          bookings_placement_request_cancellations.sent_at IS NOT NULL
          OR school_cancellations_bookings_placement_requests.sent_at IS NOT NULL
        SQL
    }

    scope :not_cancelled, lambda {
      left_joins(:candidate_cancellation, :school_cancellation)
        .where(bookings_placement_request_cancellations: { sent_at: nil })
        .where(school_cancellations_bookings_placement_requests: { sent_at: nil })
    }

    scope :requiring_attention, lambda {
      excluding_old_expired_requests
        .without_booking
        .left_joins(:candidate_cancellation)
        .merge(Cancellation.unviewed)
        .merge(Cancellation.sent.or(Cancellation.where(id: nil)))
        .left_joins(:school_cancellation)
        .where(school_cancellations_bookings_placement_requests: { id: nil })
    }

    scope :withdrawn, lambda {
      without_booking
        .joins(:candidate_cancellation)
        .merge(Cancellation.sent.order(sent_at: :desc))
    }

    scope :withdrawn_but_unviewed, lambda {
      withdrawn.merge Cancellation.unviewed
    }

    scope :rejected, lambda {
      without_booking
        .joins(:school_cancellation)
        .merge(Cancellation.sent.order(sent_at: :desc))
    }

    scope :old_expired_requests, lambda {
      left_joins(:placement_date)
      .where(
        'bookings_placement_dates.date < ? OR
        (bookings_placement_requests.created_at < ? AND bookings_placement_dates.date IS NULL)',
        1.month.ago, 2.months.ago
      )
    }

    scope :excluding_old_expired_requests, lambda {
      left_joins(:placement_date)
      .where(
        'bookings_placement_dates.date >= ? OR
        (bookings_placement_requests.created_at >= ? AND bookings_placement_dates.date IS NULL)',
        1.month.ago, 2.months.ago
      )
    }

    default_scope { joins(:candidate) }

    delegate :gitis_contact, :gitis_contact=, to: :candidate

    def self.create_from_registration_session!(registration_session)
      new(
        Candidates::Registrations::RegistrationAsPlacementRequest
          .new(registration_session)
          .attributes
      ).tap do |r|
        r.experience_type = r.resolve_experience_type
        r.save!(context: :creating_placement_request_from_registration_session)
      end
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
      candidate.gitis_uuid
    end

    def dates_requested
      if placement_date.present?
        placement_date.date.to_formatted_s(:govuk)
      else
        availability
      end
    end

    def requested_subject
      subject || Bookings::Subject.unscoped.find_by!(name: subject_first_choice)
    end

    def received_on
      created_at.to_date
    end

    def status
      return 'Candidate cancellation' if booking&.accepted? && candidate_cancellation&.sent?
      return 'School cancellation'    if booking&.accepted? && school_cancellation&.sent?
      return 'Booked'                 if booking&.accepted?
      return 'Withdrawn'              if candidate_cancellation&.sent?
      return 'Rejected'               if school_cancellation&.sent?
      return 'Expired'                if expired?
      return 'Under consideration'    if under_consideration?
      return 'Flagged'                if candidate.attended_bookings.any?
      return 'Viewed'                 if viewed?

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
      school.notification_emails
    end

    delegate :name, to: :school, prefix: true

    delegate :urn, to: :school, prefix: true

    delegate :email, to: :candidate, prefix: true

    def candidate_name
      candidate.full_name
    end

    def cancellation
      [candidate_cancellation, school_cancellation].compact.find(&:sent?)
    end

    def cancelled?
      !!cancellation
    end

    def requested_on
      created_at&.to_date
    end

    def fixed_date
      placement_date&.date
    end

    def fixed_date_is_bookable?
      !!placement_date&.bookable?
    end

    def under_consideration?
      under_consideration_at.present?
    end

    def expired?
      fixed_date_expired? || flex_date_expired?
    end

    def resolve_experience_type
      return school.experience_type if flex_date?

      placement_date.experience_type
    end

    def flex_date?
      placement_date.nil?
    end

    def unclear_experience_type?
      flex_date? && (EXPERIENCE_TYPES.exclude?(experience_type) || experience_type != school.experience_type)
    end

  private

    def fixed_date_expired?
      placement_date&.date&.before?(Date.today)
    end

    def flex_date_expired?
      placement_date.nil? && created_at.before?(2.months.ago)
    end

    def completed?
      # FIXME: SE-1096 determine from booking
      false
    end

    def pre_phase3_record?
      persisted? && candidate_id_was.nil?
    end
  end
end
