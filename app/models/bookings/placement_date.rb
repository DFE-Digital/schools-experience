module Bookings
  class PlacementDate < ApplicationRecord
    belongs_to :school_profile,
      class_name: 'Schools::SchoolProfile',
      foreign_key: 'schools_school_profile_id'

    validates :school_profile, presence: true
    validates :date, presence: true

    scope :future, -> { where(arel_table[:date].gteq(Time.now)) }
    scope :past, -> { where(arel_table[:date].lt(Time.now)) }
  end
end
