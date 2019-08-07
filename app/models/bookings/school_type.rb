class Bookings::SchoolType < ApplicationRecord
  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 64 },
    uniqueness: true

  has_many :schools,
    class_name: "Bookings::School",
    foreign_key: :bookings_school_type_id
end
