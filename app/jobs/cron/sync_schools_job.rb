class Cron::SyncSchoolsJob < CronJob
  self.cron_expression = '30 4 * * *'

  def perform
    Bookings::SchoolSync.new.sync
  end
end
