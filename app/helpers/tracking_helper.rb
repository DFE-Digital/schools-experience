module TrackingHelper
  def gtm_enabled?
    ENV["GTM_ID"].present?
  end

  def gtm_id
    ENV["GTM_ID"]
  end
end
