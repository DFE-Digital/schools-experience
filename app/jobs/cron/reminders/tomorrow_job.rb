module Cron
  module Reminders
    class TomorrowJob < CronJob
      self.cron_expression = '30 9 * * *'

      # Create one Bookings::ReminderJob _per booking_, each
      # Bookings::ReminderJob, via Bookings::Reminder is responsible
      # for pulling its own information (name, email) from Gitis and should
      # individually retry if the API isn't available
      def perform
        return true unless Feature.active? :reminders

        bookings.each do |booking|
          Bookings::ReminderJob.perform_later(booking, time_until_booking)
        end
      end

      def bookings
        Bookings::Booking.not_cancelled.accepted.for_tomorrow
      end

      # This will be used for SMS and email messages in the format: "Your school experience
      # is {time_until_booking}".
      def time_until_booking
        "tomorrow"
      end
    end
  end
end
