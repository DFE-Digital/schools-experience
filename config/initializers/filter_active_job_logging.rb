require 'active_job/logging'

if !Rails.env.development?
  class ActiveJob::Logging::LogSubscriber
    # activejob-5.2.3/lib/active_job/logging.rb
    private def args_info(job)
      if job.arguments.any?
        ' with arguments: ' + job.arguments.first.to_s # Log the job class only
      else
        ''
      end
    end
  end
end
