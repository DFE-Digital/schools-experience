module Schools
  class StateMismatchError < StandardError; end

  class AuthFailedError < StandardError; end

  class InsufficientPrivilegesError < StandardError; end

  class SessionExpiredError < StandardError; end

  class NoOrganisationError < StandardError; end

  class SessionsController < ApplicationController
    include DFEAuthentication

    rescue_from AuthFailedError,    with: :authentication_failure
    rescue_from StateMismatchError, with: :authentication_failure
    rescue_from InsufficientPrivilegesError, with: :insufficient_privileges_failure
    rescue_from SessionExpiredError, with: :session_expired_failure
    rescue_from NoOrganisationError, with: :no_organisation_failure

    def show
      # nothing yet, the view just contains a 'logout' button
    end

    # This will redirect to DfE Sign-in's end session endpoint with the
    # `id_token_hint` (which is the `id_hint` we saved to the session when they
    # logged in) and the `post_logout_redirect_uri`, which is the schools
    # landing page.
    #
    # NOTE that the post_logout_redirect_uri must be configured by the DfE
    # Sign-in team and what we supply must match what's configured
    def logout
      id_token = session[:id_token]

      session.clear

      if id_token.nil?
        Rails.logger.error 'No id_token present, cannot log out from DfE Sign-in'
        return redirect_to schools_path
      end

      redirect_to(
        URI::HTTPS.build(
          host: get_oidc_client.host,
          path: '/session/end',
          query: build_logout_query(id_token)
        ).to_s,
        allow_other_host: true
      )
    end

    def create
      return redirect_to schools_dashboard_path if user_signed_in?

      check_for_errors(params[:error])
      check_state(session[:state], params[:state])

      client = get_oidc_client
      client.authorization_code = params[:code]

      userinfo = extract_userinfo(client.access_token!)

      # now we have the dfe sign-in user uuid and urn in the session, check permissions
      check_role!(userinfo[:dfe_sign_in_user_uuid], userinfo[:dfe_sign_in_org_uuid])
      populate_session(userinfo)

      redirect_to(session.delete(:return_url) || schools_dashboard_path)

    # the DfE Sign-in api returns a 404 if the resource (permission) we're looking
    # for isn't there
    rescue Faraday::ResourceNotFound, Schools::DFESignInAPI::Roles::NoOrganisationError => e
      raise InsufficientPrivilegesError, e

    # if we fail with an AttrRequired::AttrMissing error here it's likely that
    # params[:code] is missing, so raise AuthFailedError and log it
    rescue AttrRequired::AttrMissing => e
      Rails.logger.error("Login failed #{e.backtrace}")
      raise AuthFailedError
    end

  private

    def check_role!(user_uuid, organisation_uuid)
      return true unless Schools::DFESignInAPI::Client.role_check_enabled?

      if organisation_uuid.blank?
        if Schools::ChangeSchool.allow_school_change_in_app?
          return true
        else
          raise NoOrganisationError
        end
      end

      unless Schools::DFESignInAPI::Roles.new(user_uuid, organisation_uuid).has_school_experience_role?
        raise InsufficientPrivilegesError, "missing school experience administrator role - #{user_uuid} : #{organisation_uuid}"
      end
    end

    def check_state(session_state, params_state)
      if params_state != session_state
        message = sprintf("params state (%<params_state>s) doesn't match session state %<session_state>s", params_state: params_state, session_state: session_state)

        Rails.logger.error(message)

        raise StateMismatchError, message
      end
    end

    def populate_session(extracted_info)
      extracted_info.each do |key, value|
        session[key] = value
      end
    end

    def extract_userinfo(access_token)
      {}.tap do |info|
        access_token.userinfo!.tap do |userinfo|
          urn = userinfo.raw_attributes.dig("organisation", "urn")

          info[:id_token]              = access_token.id_token # store this for logout flows.
          info[:current_user]          = UserInfoDecorator.new(userinfo)
          info[:urn]                   = urn.presence && urn.to_i
          info[:school_name]           = userinfo.raw_attributes.dig("organisation", "name")
          info[:dfe_sign_in_org_uuid]  = userinfo.raw_attributes.dig("organisation", "id").presence
          info[:dfe_sign_in_user_uuid] = userinfo.sub
        end
      end
    end

    def check_for_errors(params_error)
      if params_error == 'sessionexpired'
        Rails.logger.warn("DfE Sign-in session expiry error, restarting login process")

        raise SessionExpiredError
      end

      if params_error
        Rails.logger.error("DfE Sign-in error response #{params_error}, #{params}")

        raise AuthFailedError, params_error
      end
    end

    def authentication_failure(exception)
      Sentry.capture_exception(exception)

      redirect_to schools_errors_auth_failed_path
    end

    def insufficient_privileges_failure(exception)
      Sentry.capture_exception(exception)

      redirect_to schools_errors_insufficient_privileges_path
    end

    def session_expired_failure(_exception)
      # we're redirecting to the dashboard so the user will be sent back to
      # DfE Sign-in where they can log in again.
      redirect_to schools_dashboard_path
    end

    def no_organisation_failure(exception)
      Sentry.capture_exception(exception)

      redirect_to schools_errors_insufficient_privileges_path
    end

    def build_logout_query(id_token)
      { id_token_hint: id_token, post_logout_redirect_uri: schools_url }.to_query
    end

    def show_candidate_alert_notification?
      false
    end
  end
end
