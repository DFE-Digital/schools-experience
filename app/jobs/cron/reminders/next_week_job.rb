module Cron
  module Reminders
    class NextWeekJob < CronJob
      self.cron_expression = '35 2 * * *'

      def perform
        return true unless Feature.active? :reminders

        bookings.all? do |booking|
          Bookings::ReminderJob.perform_later(booking, time_until_booking)

          despatch_sms_reminder(booking)
        end
      end

      def despatch_sms_reminder(booking)
        # The SMS message doesn't need to query the CRM for any personal data
        # so it can be despatched here rather than from the Bookings::ReminderJob
        NotifySms::CandidateBookingReminder.new(
          to: booking.contact_number,
          school_name: booking.bookings_school,
          time_until_booking: time_until_booking
        ).despatch_later!
      end

      def bookings
        Bookings::Booking.not_cancelled.accepted.for_one_week_from_now
      end

      # this string will be used in the email subject, something along the lines
      # of "Your School Experience placement at {some school} is in {one week}"
      def time_until_booking
        "one week"
      end
    end
  end
end
