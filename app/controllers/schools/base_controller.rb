module Schools
  class BaseController < ApplicationController
    include DFEAuthentication
    before_action :require_auth

    def current_school
      raise ActionController::ParameterMissing unless session[:urn].present?

      Rails.logger.debug("Looking for school #{session[:urn]}")
      @current_school ||= Bookings::School.find_by!(urn: session[:urn])
    end
  end
end
