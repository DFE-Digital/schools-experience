class Bookings::School < ApplicationRecord
  include FullTextSearch
  include GeographicSearch

  validates :name,
    presence: true,
    length: { maximum: 128 }

  has_many :bookings_schools_subjects,
    class_name: "Bookings::SchoolsSubject",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id

  has_many :subjects,
    class_name: "Bookings::Subject",
    through: :bookings_schools_subjects,
    source: :bookings_subject
end
