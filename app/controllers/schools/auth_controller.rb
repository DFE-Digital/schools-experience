module Schools
  class AuthController < ApplicationController
    include DFEAuthentication

    def auth_callback
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
