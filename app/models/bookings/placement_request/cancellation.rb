class Bookings::PlacementRequest::Cancellation < ApplicationRecord
  include ViewTrackable

  SCHOOL_REJECTION_REASONS = %w(
    fully_booked
    accepted_on_ttc
    date_not_available
    no_relevant_degree
    no_phase_availability
    candidate_not_local
    duplicate
    other
  ).freeze

  scope :candidate_cancellation, -> { where cancelled_by: 'candidate' }
  scope :school_cancellation,    -> { where cancelled_by: 'school' }

  scope :sent, -> { where.not sent_at: nil }

  belongs_to :placement_request,
    class_name: 'Bookings::PlacementRequest',
    foreign_key: 'bookings_placement_request_id'

  validates :bookings_placement_request_id, uniqueness: true
  validates :cancelled_by, inclusion: %w(candidate school)
  validate :placement_request_not_closed, on: :create, if: :placement_request

  validates :reason, presence: true, on: %i(school_cancellation candidate_cancellation)
  validates :reason, presence: true, on: :rejection, if: -> { rejection_category == 'other' }

  validates :rejection_category, inclusion: SCHOOL_REJECTION_REASONS, on: :rejection

  delegate \
    :candidate_email,
    :candidate_name,
    :candidate,
    :contact_uuid,
    :gitis_contact,
    :gitis_contact=,
    :dates_requested,
    :token,
    :booking,
    :placement_date,
    to: :placement_request

  delegate :name, :urn, to: :school, prefix: true

  def school
    booking ? booking.bookings_school : placement_request.school
  end

  def school_email
    school.notification_emails
  end

  def sent!
    update! sent_at: DateTime.now unless sent?
  end

  def sent?
    sent_at.present? && !sent_at_changed? # check its actually been sent
  end

  def booking_date
    booking.date.to_formatted_s(:govuk)
  end

  def dates_requested
    if placement_request&.booking.present?
      placement_request.booking.date.to_formatted_s(:govuk)
    else
      placement_request.dates_requested
    end
  end

  def cancelled_by_school?
    cancelled_by == 'school'
  end

  def cancelled_by_candidate?
    cancelled_by == 'candidate'
  end

  def rejection_description
    humanised_rejection_category || reason
  end

  def humanised_rejection_category
    return nil if rejection_category == 'other' || rejection_category.nil?

    I18n.t(
      %w(
        helpers
        label
        bookings_placement_request_cancellation
        rejection_category
      ).push(rejection_category).join('.')
    )
  end

private

  def placement_request_not_closed
    if placement_request.closed?
      errors.add :placement_request, 'is already closed'
    end
  end
end
