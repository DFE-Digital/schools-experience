module Bookings
  class Booking < ApplicationRecord
    MIN_BOOKING_DELAY = 1.day.freeze

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
        on_or_after: -> { MIN_BOOKING_DELAY.from_now.to_date },
        before: -> { 2.years.from_now },
        type: :date
      }

    validate on: :updating_date do
      errors.add :date, :not_changed unless date_changed?
    end

    validates :bookings_placement_request, presence: true
    validates :bookings_placement_request_id, presence: true
    validates :bookings_subject, presence: true
    validates :bookings_school, presence: true
    validates :duration, presence: true, numericality: { greater_than: 0 }
    validates :attended, inclusion: [nil], if: -> { bookings_placement_request&.cancelled? }
    validates :attended, inclusion: [true, false], on: :attendance

    validates :contact_name, presence: true, on: %i(create acceptance)
    validates :contact_number, presence: true, on: %i(create acceptance)
    validates :contact_number, phone: true, if: -> { contact_number.present? }
    validates :contact_email, presence: true, on: %i(create acceptance)
    validates :contact_email, email_format: true, if: -> { contact_email.present? }

    validates :candidate_instructions, presence: true, on: :acceptance_email_preview

    before_validation(if: :contact_email) { self.contact_email = contact_email.to_s.strip }

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
      :gitis_contact=,
      :fetch_gitis_contact,
      :contact_uuid,
      :candidate_email,
      :candidate_name,
      :cancelled?,
      :cancellation,
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

    scope :days_in_the_future, ->(days_away) { where(date: days_away.from_now.to_date) }
    scope :tomorrow,           -> { days_in_the_future(1.day) }
    scope :one_week_from_now,  -> { days_in_the_future(7.days) }

    def self.from_placement_request(placement_request)
      # only populate the date if it's in the future
      date = if placement_request&.fixed_date_is_bookable?
               placement_request.fixed_date
             end

      new(
        bookings_school: placement_request.school,
        bookings_placement_request: placement_request,
        date: date,
        bookings_subject_id: placement_request.requested_subject.id,
        placement_details: placement_request.school.placement_info
      )
    end

    def self.last_accepted_booking_by(school)
      school.bookings.accepted.order(id: 'desc').first
    end

    # on subsequent placement request acceptances, pre-populate the contact details and
    # candidate instructions to shorten the process
    def populate_contact_details
      last_booking = Bookings::Booking.last_accepted_booking_by(bookings_school)

      return false unless last_booking.present?

      assign_attributes(
        contact_name: last_booking.contact_name,
        contact_email: last_booking.contact_email,
        contact_number: last_booking.contact_number,
        location: last_booking.location,
      )

      true
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

    def in_future?
      date > Date.today
    end

    def cancellable?
      in_future? && !cancelled?
    end

    def editable_date?
      in_future? && !cancelled?
    end
  end
end
