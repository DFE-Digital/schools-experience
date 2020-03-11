module Bookings
  # ReminderBuilder takes a single booking/period, builds a Bookings::Reminder
  # object and enqueues it (creating a mailer job). This allows a the caller (ie the
  # schedule in Cron::Reminders) to create large numbers of jobs without hitting
  # Gitis too hard at once.
  class ReminderBuilder < ApplicationJob
    queue_as :default

    def perform(booking, time_until_booking)
      Bookings::Reminder.new(booking, time_until_booking).enqueue
    end
  end
end
