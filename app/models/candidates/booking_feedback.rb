class Candidates::BookingFeedback < ApplicationRecord
  enum effect_on_decision: {
    negatively: 0,
    positively: 1,
    unaffected: 2,
  }

  belongs_to :booking,
    class_name: "Bookings::Booking",
    foreign_key: :bookings_booking_id

  validates :bookings_booking_id, uniqueness: true

  validates :gave_realistic_impression, inclusion: [true, false]
  validates :covered_subject_of_interest, inclusion: [true, false]
  validates :influenced_decision, inclusion: [true, false]
  validates :intends_to_apply, inclusion: [true, false]
  validates :effect_on_decision, presence: true
end
