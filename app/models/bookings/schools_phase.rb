class Bookings::SchoolsPhase < ApplicationRecord
  belongs_to :bookings_school,
    class_name: "Bookings::School",
    optional: true

  belongs_to :bookings_phase,
    class_name: "Bookings::Phase",
    optional: true

  validates_associated :bookings_phase, :bookings_school

  validates :bookings_school_id,
    presence: true

  validates :bookings_phase_id,
    presence: true,
    uniqueness: { scope: :bookings_school_id }
end
