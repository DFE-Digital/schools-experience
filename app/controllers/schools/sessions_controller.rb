module Schools
  class StateMissmatchError < StandardError; end
  class AuthFailedError < StandardError; end

  class SessionsController < ApplicationController
    include DFEAuthentication

    rescue_from AuthFailedError,     with: -> { redirect_to schools_errors_auth_failed_path }
    rescue_from StateMissmatchError, with: -> { redirect_to schools_errors_auth_failed_path }

    def show
      # nothing yet, the view just contains a 'logout' button
    end

    def destroy
      Rails.logger.warn("Clearing session: #{session.to_json}")
      session.clear
      redirect_to root_path
    end

    def create
      check_state(session[:state], params[:state])

      client                    = get_oidc_client
      client.authorization_code = params[:code]
      access_token              = client.access_token!
      userinfo                  = access_token.userinfo!
      session[:id_token]        = access_token.id_token # store this for logout flows.
      session[:current_user]    = userinfo
      session[:urn]             = userinfo.raw_attributes.dig("organisation", "urn").to_i

      Rails.logger.info("Logged in #{session[:current_user]}, urn: #{session[:urn]}")

      redirect_to(session.delete(:return_url) || schools_dashboard_path)

    # if we fail with an AttrRequired::AttrMissing error here it's likely that
    # params[:code] is missing, so raise AuthFailedError and log it
    rescue AttrRequired::AttrMissing => e
      Rails.logger.error("Login failed #{e.backtrace}")
      raise AuthFailedError
    end

  private

    def check_state(session_state, params_state)
      if params_state != session_state
        Rails.logger.error(
          "params state (%<params_state>s) doesn't match session state %<session_state>s" % {
            params_state: params_state,
            session_state: session_state
          }
        )

        raise StateMissmatchError
      end
    end
  end
end
