class Cron::SyncSchoolsJob < ApplicationJob
  def perform
    Bookings::SchoolSync.new.sync
  end
end
