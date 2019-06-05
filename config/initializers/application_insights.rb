unless Rails.env.test?
  Rails.application.configure do
    if (app_insights_key = ENV["APPINSIGHTS_INSTRUMENTATIONKEY"]) && app_insights_key.present?
      # the optional extra params are buffer_size (= 500) and send_interval (= 60),
      # leaving for now as they appear sensible
      config.middleware.use(ApplicationInsights::Rack::TrackRequest, app_insights_key)
      if 'true' ==  ENV["APPINSIGHTS_JAVASCRIPT_ENABLED"]
          config.middleware.use(ApplicationInsights::Rack::InjectJavaScriptTracking, app_insights_key)
      end
    end

    # # This isn't needed _until_ we want to track events and metrics in addition
    # # to the Rails app middleware (ApplicationInsights::Rack::TrackRequest). More
    # # info here:
    #
    # # https://github.com/microsoft/ApplicationInsights-Ruby
    # # https://github.com/microsoft/ApplicationInsights-Home/wiki#getting-an-application-insights-instrumentation-key
    #
    # sender = ApplicationInsights::Channel::AsynchronousSender.new
    # queue = ApplicationInsights::Channel::AsynchronousQueue.new(sender)
    # channel = ApplicationInsights::Channel::TelemetryChannel.new(nil, queue)
    #
    # TELEMETRY_CLIENT = ApplicationInsights::TelemetryClient.new(app_insights_key, channel).tap do |tc|
    #   # flush telemetry if we have 10 or more telemetry items in our queue
    #   tc.channel.queue.max_queue_length = 10
    #   # send telemetry to the service in batches of 5
    #   tc.channel.sender.send_buffer_size = 5
    #   # the background worker thread will be active for 5 seconds before it shuts down. if
    #   # during this time items are picked up from the queue, the timer is reset.
    #   tc.channel.sender.send_time = 5
    #   # the background worker thread will poll the queue every 0.5 seconds for new items
    #   tc.channel.sender.send_interval = 0.5
    # end
  end
end
