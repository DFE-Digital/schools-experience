module Bookings
  class PlacementDate < ApplicationRecord
    belongs_to :school_profile,
      class_name: 'Schools::SchoolProfile',
      foreign_key: 'schools_school_profile_id'

    validates :school_profile, presence: true
    validates :date, presence: true
    validates :duration,
      presence: true,
      numericality: {
        greater_than_or_equal_to: 1,
        less_than: 100
      }

    scope :future, -> { where(arel_table[:date].gteq(Time.now)) }
    scope :past, -> { where(arel_table[:date].lt(Time.now)) }
    scope :in_date_order, -> { order(date: 'asc') }
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    def to_s
      "%<date>s (%<duration>d %<unit>s)" % {
        date: date.to_formatted_s(:govuk),
        duration: duration,
        unit: "day".pluralize(duration)
      }
    end
  end
end
