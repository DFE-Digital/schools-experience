module Schools
  class SchoolNotRegistered < StandardError; end
  class MissingURN < StandardError; end

  class BaseController < ApplicationController
    self.forgery_protection_origin_check = false

    include GitisAccess
    self.use_gitis_cache = true

    include DFEAuthentication
    before_action :require_auth
    before_action :set_current_school
    before_action :set_site_header_text
    before_action :ensure_onboarded

    rescue_from MissingURN, with: -> { redirect_to schools_errors_no_school_path }
    rescue_from SchoolNotRegistered, with: -> { redirect_to schools_errors_not_registered_path }

    def current_school
      urn = session[:urn]
      raise MissingURN, 'urn is missing, unable to match with school' unless urn.present?

      @current_school ||= retrieve_school(urn)
    end
    alias_method :set_current_school, :current_school

  private

    def set_site_header_text
      @site_header_text = "Manage school experience"
    end

    def retrieve_school(urn)
      unless (school = Bookings::School.find_by(urn: urn))
        raise SchoolNotRegistered, "school #{urn} not found" unless school.present?
      end

      school
    end

    def ensure_onboarded
      unless @current_school.private_beta?
        Rails.logger.warn("%<school_name>s tried to access %<page>s before completing profile" % {
          school_name: @current_school.name,
          page: request.path
        })

        redirect_to schools_dashboard_path
      end
    end
  end
end
