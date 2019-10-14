module Bookings
  class Booking < ApplicationRecord
    belongs_to :bookings_placement_request,
      class_name: 'Bookings::PlacementRequest',
      inverse_of: :booking

    belongs_to :bookings_subject,
      class_name: 'Bookings::Subject'

    belongs_to :bookings_school,
      class_name: 'Bookings::School'

    has_one :candidate_cancellation, through: :bookings_placement_request
    has_one :school_cancellation, through: :bookings_placement_request

    validates :date,
      presence: true,
      on: :create
    validates :date,
      if: -> { date_changed? },
      timeliness: {
        on_or_after: :today,
        before: -> { 2.years.from_now },
        type: :date
      }

    validates :bookings_placement_request, presence: true
    validates :bookings_placement_request_id, presence: true
    validates :bookings_subject, presence: true
    validates :bookings_school, presence: true
    validates :duration, presence: true, numericality: { greater_than: 0 }

    delegate \
      :availability,
      :degree_stage,
      :degree_stage_explaination,
      :degree_subject,
      :has_dbs_check,
      :objectives,
      :teaching_stage,
      :token,
      :build_candidate_cancellation,
      :closed?,
      :received_on,
      :gitis_contact,
      :fetch_gitis_contact,
      :contact_uuid,
      :candidate_email,
      :candidate_name,
      :cancelled?,
      :cancellable?,
      to: :bookings_placement_request

    scope :not_cancelled, -> { joins(:bookings_placement_request).merge(PlacementRequest.not_cancelled) }
    scope :upcoming, -> { not_cancelled.accepted.future }

    scope :accepted, -> { where.not(accepted_at: nil) }
    scope :previous, -> { where(arel_table[:date].lteq(Date.today)) }
    scope :future, -> { where(arel_table[:date].gteq(Date.today)) }
    scope :attendance_unlogged, -> { where(attended: nil) }

    scope :with_unviewed_candidate_cancellation, -> do
      joins(bookings_placement_request: :candidate_cancellation)
        .where(bookings_placement_request_cancellations: { viewed_at: nil })
    end

    scope :to_manage, -> do
      not_cancelled
      .attendance_unlogged
      .accepted
      .future
    end

    scope :requiring_attention, -> do
      where(id: with_unviewed_candidate_cancellation.select('id')).or \
        where(id: to_manage.select('id'))
    end

    scope :historical, -> do
      previous.accepted
    end

    def self.from_confirm_booking(confirm_booking)
      new(
        date: confirm_booking.date,
        bookings_subject_id: confirm_booking.bookings_subject_id,
        placement_details: confirm_booking.placement_details
      )
    end

    def status
      bookings_placement_request.status
    end

    def placement_start_date_with_duration
      if bookings_placement_request&.placement_date&.present?
        [date.to_formatted_s(:govuk), 'for', duration_days].join(' ')
      else
        date.to_formatted_s(:govuk)
      end
    end

    def duration_days
      duration.to_s + ' day'.pluralize(duration)
    end

    # stage one of the placement request acceptance mini-wizard
    def booking_confirmed?
      Schools::PlacementRequests::ConfirmBooking.new(
        date: date,
        placement_details: placement_details,
        bookings_subject_id: bookings_subject_id
      ).valid?
    end

    # stage two of the placement request acceptance mini-wizard
    def more_details_added?
      Schools::PlacementRequests::AddMoreDetails.new(
        contact_name: contact_name,
        contact_number: contact_number,
        contact_email:  contact_email,
        location:  location
      ).valid?
    end

    # stage three of the placement request acceptance mini-wizard
    def reviewed_and_candidate_instructions_added?
      Schools::PlacementRequests::ReviewAndSendEmail.new(
        candidate_instructions: candidate_instructions
      ).valid?
    end

    def accepted?
      accepted_at.present?
    end

    def accept!
      return true if accepted?

      update(accepted_at: Time.zone.now)
    end

    def reference
      bookings_placement_request.token.first(5)
    end
  end
end
