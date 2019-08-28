# FIXME needs to inherit from CronJob once its merged
class Cron::SyncSubjectsWithGitisJob < ApplicationJob
#  self.cron_expression = '30 3 * * *' # FIXME reenabled for scheduling

  def perform
    Bookings::SubjectSync.synchronise(crm)
  end

private

  def token
    Bookings::Gitis::Auth.new.token
  end

  def crm
    Bookings::Gitis::CRM.new(token)
  end
end
