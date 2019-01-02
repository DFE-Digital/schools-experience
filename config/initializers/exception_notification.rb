if ENV['SLACK_WEBHOOK'].present?
  slack_opts = {
    :webhook_url => ENV['SLACK_WEBHOOK'],
    :additional_parameters => {
      :mrkdwn => true
    }
  }

  if ENV['SLACK_CHANNEL'].present?
    slack_opts[:channel] = ENV['SLACK_CHANNEL']
  end

  if ENV['SLACK_ENV'].present?
    slack_opts[:additional_fields] = [
      { title: "Deployment Environment", value: ENV['SLACK_ENV'].to_s }
    ]
  end

  Rails.application.config.middleware.use ExceptionNotification::Rack, slack: slack_opts
end
