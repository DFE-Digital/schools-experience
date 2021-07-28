# TEMP: removes the subject sync cron job; once
# this has been shipped to prod it can be removed.
class Cron::SyncSubjectsWithGitisJob < CronJob
  self.cron_expression = "30 3 * * *"

  class << self
    def jobs
      Delayed::Job
        .where("handler LIKE ?", "%job_class: #{name}%")
        .where.not(cron: nil)
    end

    def schedule
      jobs.destroy_all
    end
  end

  def perform; end
end
