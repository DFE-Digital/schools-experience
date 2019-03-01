module GoogleAnalyticsHelper
  def google_analytics_enabled?
    ENV['GA_TRACKING_ID'].present?
  end

  def google_analytics_tracking_id
    ENV.fetch('GA_TRACKING_ID')
  end
end
