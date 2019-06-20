module Bookings
  class PlacementDate < ApplicationRecord
    belongs_to :bookings_school,
      class_name: 'Bookings::School',
      foreign_key: 'bookings_school_id'

    has_many :placement_requests,
      class_name: 'Bookings::PlacementRequest',
      inverse_of: :placement_date,
      foreign_key: :bookings_placement_date_id

    validates :bookings_school, presence: true
    validates :duration,
      presence: true,
      numericality: {
        greater_than_or_equal_to: 1,
        less_than: 100
      }
    validates :date, presence: true
    validate :date_must_be_in_the_future, on: :create

    scope :future, -> { where(arel_table[:date].gteq(Time.now)) }
    scope :past, -> { where(arel_table[:date].lt(Time.now)) }
    scope :in_date_order, -> { order(date: 'asc') }
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    scope :available, -> { active.future.in_date_order }

    def to_s
      "%<date>s (%<duration>d %<unit>s)" % {
        date: date.to_formatted_s(:govuk),
        duration: duration,
        unit: "day".pluralize(duration)
      }
    end

  private

    def date_must_be_in_the_future
      if date.present? && date <= Date.today
        errors.add(:date, "Date must be in the future")
      end
    end
  end
end
