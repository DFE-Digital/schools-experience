module Bookings
  class PlacementDate < ApplicationRecord
    belongs_to :bookings_school,
      class_name: 'Bookings::School',
      foreign_key: 'bookings_school_id'

    has_many :placement_requests,
      class_name: 'Bookings::PlacementRequest',
      inverse_of: :placement_date,
      foreign_key: :bookings_placement_date_id

    has_many :placement_date_subjects,
      class_name: 'Bookings::PlacementDateSubject',
      inverse_of: :bookings_placement_date,
      foreign_key: :bookings_placement_date_id,
      dependent: :destroy

    has_many :subjects,
      class_name: 'Bookings::Subject',
      through: :placement_date_subjects,
      source: :bookings_subject

    accepts_nested_attributes_for :subjects, allow_destroy: true

    validates :bookings_school, presence: true
    validates :duration,
      presence: true,
      numericality: {
        greater_than_or_equal_to: 1,
        less_than: 100
      }

    validates :date,
      timeliness: {
        on_or_after: :today,
        before: -> { 2.years.from_now },
        type: :date
      },
      presence: true,
      on: :create

    with_options if: :published? do
      validates :max_bookings_count, numericality: { greater_than: 0, allow_nil: true }
      validates :subjects, presence: true, if: %i(subject_specific? published?)
      validates :subjects, absence: true, unless: :subject_specific?
    end

    scope :future, -> { where(arel_table[:date].gteq(Time.now)) }
    scope :past, -> { where(arel_table[:date].lt(Time.now)) }
    scope :in_date_order, -> { order(date: 'asc') }
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    scope :available, -> { published.active.future.in_date_order }
    scope :published, -> { where.not published_at: nil }

    # 'supporting subjects' are dates belonging to phases where
    # teachers teach a particular subject - secondary and college
    scope :supporting_subjects, -> { where(supports_subjects: true) }

    # 'not supporting subjects' are dates belonging to phases where teachers
    # don't yet teach a specific subject - primary and early years
    scope :not_supporting_subjects, -> { where(supports_subjects: false) }

    def to_s
      "%<date>s (%<duration>d %<unit>s)" % {
        date: date.to_formatted_s(:govuk),
        duration: duration,
        unit: "day".pluralize(duration)
      }
    end

    def has_subjects?
      placement_date_subjects.any?
    end

    def has_limited_availability?
      max_bookings_count.present?
    end

    def published?
      published_at.present?
    end
  end
end
