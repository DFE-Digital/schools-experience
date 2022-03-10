module Schools
  module PlacementDates
    class RecurrencesSelection
      include ActiveModel::Model
      include ActiveModel::Attributes
      # Multi parameter date fields aren't yet support by ActiveModel so we
      # need to include the support for them from ActiveRecord.
      require "active_record/attribute_assignment"
      include ::ActiveRecord::AttributeAssignment

      RECURRENCE_PERIODS = {
        daily: "daily",
        weekly: "weekly",
        fortnightly: "fortnightly",
        custom: "custom"
      }.freeze.with_indifferent_access
      WEEKDAYS = %i[monday tuesday wednesday thursday friday].freeze

      attribute :start_at, :date
      attribute :end_at, :date
      attribute :recurrence_period
      attribute :custom_recurrence_days

      validates :start_at, presence: true
      validates :end_at, presence: true
      validates :recurrence_period, presence: true
      validates :end_at, timeliness: {
        after: :start_at,
        on_or_before: ->(selection) { selection.start_at + 4.months },
        type: :date
      }
      validate :custom_recurrence_days_all_in_array, if: :recurrence_period_custom?
      validate :has_recurring_dates, if: :can_calculate_recurring_dates?

      def self.new_from_date(placement_date)
        new(start_at: placement_date.date)
      end

      def recurring_dates
        schedule = IceCube::Schedule.new(start_at)

        case recurrence_period
        when RECURRENCE_PERIODS[:daily]
          schedule.add_recurrence_rule IceCube::Rule.daily.day(*WEEKDAYS)
        when RECURRENCE_PERIODS[:weekly]
          schedule.add_recurrence_rule IceCube::Rule.weekly
        when RECURRENCE_PERIODS[:fortnightly]
          schedule.add_recurrence_rule IceCube::Rule.weekly(2)
        when RECURRENCE_PERIODS[:custom]
          schedule.add_recurrence_rule IceCube::Rule.daily.day(*custom_recurrence_days.map(&:to_sym))
        end

        schedule.occurrences_between(start_at + 1.day, end_at, spans: true).map(&:to_date)
      end

    private

      def custom_recurrence_days_all_in_array
        return unless recurrence_period == RECURRENCE_PERIODS[:custom]

        days = custom_recurrence_days || []

        if days.empty? || days.any? { |d| !d.in?(WEEKDAYS.map(&:to_s)) }
          errors.add(:custom_recurrence_days, :inclusion)
        end
      end

      def can_calculate_recurring_dates?
        end_at.present? && recurrence_period.present? && (
          custom_recurrence_days.present? || recurrence_period != RECURRENCE_PERIODS[:custom]
        )
      end

      def has_recurring_dates
        return unless recurring_dates.empty?

        errors.add(:end_at, :no_recurring_dates)
      end

      def recurrence_period_custom?
        recurrence_period == RECURRENCE_PERIODS[:custom]
      end
    end
  end
end
