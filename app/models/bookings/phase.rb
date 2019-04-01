class Bookings::Phase < ApplicationRecord
  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 32 },
    uniqueness: true

  has_many :bookings_schools_phases,
    class_name: "Bookings::SchoolsPhase",
    inverse_of: :bookings_phase,
    foreign_key: :bookings_phase_id

  has_many :schools,
    class_name: "Bookings::School",
    through: :bookings_schools_phases,
    source: :bookings_school

  acts_as_list
  default_scope -> { order(:position) }

  def self.secondary
    find_by! name: 'Secondary'.freeze
  end

  def self.college
    find_by! name: '16 plus'.freeze
  end
end
