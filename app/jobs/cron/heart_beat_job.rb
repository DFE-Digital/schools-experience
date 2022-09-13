class Cron::HeartBeatJob < ApplicationJob
  def perform
    Yabeda.gse.delayed_job_heart_beat.increment({}, by: 1)
    Yabeda.gse.sidekiq_heart_beat.increment({}, by: 1)
  end
end
