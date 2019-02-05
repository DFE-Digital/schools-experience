class Bookings::SchoolsPhase < ApplicationRecord
  belongs_to :bookings_school,
    class_name: "Bookings::School"

  belongs_to :bookings_phase,
    class_name: "Bookings::Phase"

  validates :bookings_school, presence: true
  validates :bookings_phase, presence: true

  validates :bookings_phase_id,
    uniqueness: { scope: :bookings_school_id }
end
