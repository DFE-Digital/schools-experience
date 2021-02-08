# FIXME: needs to inherit from CronJob once its merged
class Cron::SyncSubjectsWithGitisJob < CronJob
  self.cron_expression = '30 3 * * *'
  delegate :crm, to: Bookings::Gitis::Factory

  def perform
    Bookings::SubjectSync.synchronise(crm)
  end
end
