class Cron::HeartBeatJob < CronJob
  self.cron_expression = "* * * * *"

  def perform
    Yabeda.gse.delayed_job_heart_beat.increment({}, by: 1)
  end
end