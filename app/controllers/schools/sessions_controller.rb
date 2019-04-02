module Schools
  class SessionsController < ApplicationController
    include DFEAuthentication

    def show
    end

    def destroy
      session[:id_token]     = nil
      session[:current_user] = nil
      session[:state]        = nil

      redirect_to root_path
    end

    def create
      raise "State missmatch error" if params[:state] != session[:state]

      client = get_oidc_client
      client.authorization_code = params[:code]
      access_token = client.access_token!
      userinfo = access_token.userinfo!
      session[:id_token] = access_token.id_token # store this for logout flows.
      session[:current_user] = userinfo

      redirect_to session[:return_url]
    end
  end
end
