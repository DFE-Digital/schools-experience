module AnalyticsTracking
  extend ActiveSupport::Concern

  included do
    before_action :set_analytics_tracking_uuid

  private

    def set_analytics_tracking_uuid
      if cookies[:analytics_tracking_uuid].blank?
        cookies[:analytics_tracking_uuid] = SecureRandom.uuid
      end
    end
  end
end
