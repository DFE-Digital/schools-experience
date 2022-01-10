module Cron
  module Reminders
    class NextWeekJob < CronJob
      self.cron_expression = '35 9 * * *'

      def perform
        return true unless Feature.active? :reminders

        bookings.all? do |booking|
          Bookings::ReminderJob.perform_later(booking, time_until_booking)
        end
      end

      def bookings
        Bookings::Booking.not_cancelled.accepted.for_one_week_from_now
      end

      # This will be used for SMS and email messages in the format: "Your school experience
      # is {time_until_booking}".
      def time_until_booking
        "in one week"
      end
    end
  end
end
