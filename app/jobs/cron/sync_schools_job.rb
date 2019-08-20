class Cron::SyncSchoolsJob < CronJob
  self.cron_expression = ENV.fetch('GIAS_SYNC_SCHEDULE') { '30 4 * * *' }

  def perform
    Bookings::SchoolSync.new.sync
  end
end
