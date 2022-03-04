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
      # attribute :custom_recurrence_period

      validates :start_at, presence: true
      validates :end_at, presence: true
      validates :recurrence_period, presence: true
      validate :end_at_after_start_at

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
        end

        # TODO: These occurrences include the start_at date (see specs). Need to make sure we aren't creating
        # duplicates when we publish the dates further in the flow.
        schedule.occurrences_between(start_at, end_at, spans: true).map(&:to_date)
      end

    private

      def end_at_after_start_at
        return if end_at.blank? || start_at.blank?

        if end_at <= start_at
          errors.add(:end_at, :before_placement_start_at)
        end
      end
    end
  end
end
