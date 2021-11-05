class Cron::SyncSchoolsJob < CronJob
  self.cron_expression = '30 7 * * *'

  def perform
    Bookings::SchoolSync.new.sync
  end
end
