module Bookings
  class Booking < ApplicationRecord
    belongs_to :bookings_placement_request,
      class_name: 'Bookings::PlacementRequest'

    belongs_to :bookings_subject,
      class_name: 'Bookings::Subject'

    belongs_to :bookings_school,
      class_name: 'Bookings::School'

    validates :date, presence: true
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
      to: :bookings_placement_request

    scope :upcoming, -> { where(arel_table[:date].between(Time.now..2.weeks.from_now)) }
    scope :accepted, -> { where.not(accepted_at: nil) }

    def self.from_confirm_booking(confirm_booking)
      new(
        date: confirm_booking.date,
        bookings_subject_id: confirm_booking.bookings_subject_id,
        placement_details: confirm_booking.placement_details
      )
    end

    # FIXME this will eventually be handled 'higher up', probably by
    # a helper or directly in the view
    def candidate
      Bookings::Gitis::CRM.new('abc123').find(1)
    end

    def received_on
      bookings_placement_request.created_at.to_date
    end

    def status
      "New"
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
  end
end
