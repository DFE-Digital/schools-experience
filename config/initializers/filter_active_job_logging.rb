require 'active_job/logging'

if !Rails.env.development?
  class ActiveJob::Logging::LogSubscriber
    # activejob-5.2.3/lib/active_job/logging.rb

  private

    def args_info(_job)
      ''
    end
  end
end
