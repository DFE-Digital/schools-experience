class Bookings::Phase < ApplicationRecord
  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 32 }

  has_many :bookings_schools_phases,
    class_name: "Bookings::SchoolsPhase",
    inverse_of: :bookings_phase,
    foreign_key: :bookings_phase_id

  has_many :schools,
    class_name: "Bookings::School",
    through: :bookings_schools_phases,
    source: :bookings_school
end
