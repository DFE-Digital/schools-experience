module Cron
  module Reminders
    class AddAvailabilityJob < ApplicationJob
      def perform
        profiles_created_yesterday_with_no_availability.each do |booking_profile|
          NotifyEmail::SchoolAddAvailabilityReminder.new(
            to: booking_profile.admin_contact_email,
          ).despatch_later!
        end
      end

    private

      def profiles_created_yesterday_with_no_availability
        Bookings::Profile.where(created_at: Date.yesterday.beginning_of_day...Date.yesterday.end_of_day)
           .joins(:school)
           .merge(Bookings::School.without_availability)
      end
    end
  end
end
