module Schools
  class SchoolNotRegistered < StandardError; end

  class BaseController < ApplicationController
    include DFEAuthentication
    before_action :require_auth
    before_action :set_current_school
    before_action :set_site_header_text

    rescue_from ActionController::ParameterMissing, with: -> { redirect_to schools_errors_no_school_path }
    rescue_from SchoolNotRegistered, with: -> { redirect_to schools_errors_not_registered_path }

    def current_school
      urn = session[:urn]
      raise ActionController::ParameterMissing, 'urn is missing, unable to match with school' unless urn.present?

      Rails.logger.debug("Looking for school #{urn}")
      @current_school ||= retrieve_school(urn)
    end
    alias_method :set_current_school, :current_school

    def set_site_header_text
      @site_header_text = "Manage school experience"
    end

  private

    def retrieve_school(urn)
      unless (school = Bookings::School.find_by(urn: urn))
        raise SchoolNotRegistered, "school #{urn} not found" unless school.present?
      end

      school
    end
  end
end
