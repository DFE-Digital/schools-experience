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

    rescue_from MissingURN, with: :no_school_selected
    rescue_from SchoolNotRegistered, with: -> { redirect_to schools_errors_not_registered_path }
    rescue_from Bookings::Gitis::API::BadResponseError, with: :gitis_retrieval_error
    rescue_from Bookings::Gitis::API::ConnectionFailed, with: :gitis_retrieval_error

    def current_school
      raise MissingURN, 'urn is missing, unable to match with school' if current_urn.blank?

      @current_school ||= retrieve_school(current_urn)
    end
    alias_method :set_current_school, :current_school

  private

    def current_urn
      session[:urn]
    end
    helper_method :current_urn

    def set_site_header_text
      @site_header_text = "Manage school experience"
    end

    def retrieve_school(urn)
      raise MissingURN if urn.blank?

      Bookings::School.find_by!(urn: urn)
    rescue ActiveRecord::RecordNotFound
      raise SchoolNotRegistered, "school #{urn} not found"
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

    def gitis_retrieval_error(exception)
      if Rails.env.production?
        ExceptionNotifier.notify_exception exception
        Raven.capture_exception exception
      end

      render 'shared/failed_gitis_connection', status: :service_unavailable
    end

    def no_school_selected(exception)
      if Schools::ChangeSchool.allow_school_change_in_app?
        redirect_to schools_change_path
      else
        ExceptionNotifier.notify_exception exception
        Raven.capture_exception exception

        redirect_to schools_errors_insufficient_privileges_path
      end
    end
  end
end
