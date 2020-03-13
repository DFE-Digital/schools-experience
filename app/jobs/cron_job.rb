class CronJob < ActiveJob::Base
  class_attribute :cron_expression

  class << self
    def schedule
      remove_scheduled if scheduled? && incorrect_schedule?

      set(cron: cron_expression).perform_later unless scheduled?
    end

  private

    def remove_scheduled
      delayed_job.destroy if scheduled?
    end

    def scheduled?
      delayed_job.present?
    end

    def incorrect_schedule?
      delayed_job.cron != cron_expression
    end

    def delayed_job
      jobs.first
    end

    def jobs
      Delayed::Job
        .where("handler LIKE ?", "%job_class: #{name}%")
        .where.not(cron: nil)
    end
  end
end
