module TrackingHelper
  def google_analytics_enabled?
    ENV["GA_TRACKING_ID"].present?
  end

  def google_analytics_tracking_id
    ENV["GA_TRACKING_ID"]
  end

  def gtm_enabled?
    ENV["GTM_ID"].present?
  end

  def gtm_id
    ENV["GTM_ID"]
  end
end
