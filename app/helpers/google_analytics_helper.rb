module GoogleAnalyticsHelper
  def google_analytics_enabled?
    ENV.has_key?('GA_TRACKING_ID')
  end

  def google_analytics_tracking_id
    ENV.fetch('GA_TRACKING_ID')
  end
end
