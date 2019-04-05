module Schools
  class BaseController < ApplicationController
    include DFEAuthentication
    before_action :require_auth

    rescue_from ActionController::ParameterMissing, with: -> { redirect_to schools_errors_no_school_path }
    rescue_from ActiveRecord::RecordNotFound, with: -> { redirect_to schools_errors_not_registered_path }

    def current_school
      raise ActionController::ParameterMissing, 'urn is missing, unable to match with school' unless session[:urn].present?

      Rails.logger.debug("Looking for school #{session[:urn]}")
      @current_school ||= Bookings::School.find_by!(urn: session[:urn])
    end
  end
end
