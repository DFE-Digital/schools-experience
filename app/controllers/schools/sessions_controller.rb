module Schools
  class SessionsController < ApplicationController
    include DFEAuthentication

    def show
      # nothing yet, the view just contains a 'logout' button
    end

    def destroy
      Rails.logger.warn("Clearing session: #{session.to_json}")
      session.clear
      redirect_to root_path
    end

    def create
      raise "State missmatch error" if params[:state] != session[:state]

      client                    = get_oidc_client
      client.authorization_code = params[:code]
      access_token              = client.access_token!
      userinfo                  = access_token.userinfo!
      session[:id_token]        = access_token.id_token # store this for logout flows.
      session[:current_user]    = userinfo
      session[:urn]             = userinfo.raw_attributes.dig("organisation", "urn").to_i

      Rails.logger.info("Logged in #{session[:current_user]}, urn: #{session[:urn]}")

      redirect_to(session.delete(:return_url) || schools_dashboard_path)
    end
  end
end
