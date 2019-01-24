class Bookings::Subject < ApplicationRecord
  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 64 }
end
