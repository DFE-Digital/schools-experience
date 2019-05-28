module AnalyticsTracking
  extend ActiveSupport::Concern

  included do
    before_action :set_analytics_tracking_uuid

  private

    def set_analytics_tracking_uuid
      if session[:analytics_tracking_uuid].blank?
        session[:analytics_tracking_uuid] = SecureRandom.uuid
      end
    end
  end
end
