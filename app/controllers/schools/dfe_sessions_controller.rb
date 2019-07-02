module Schools
  class NoIDTokenError < StandardError; end

  class DfeSessionsController < Schools::BaseController
    skip_before_action :ensure_onboarded

    # This will redirect to DfE Sign-in's end session endpoint with the
    # `id_token_hint` (which is the `id_hint` we saved to the session when they
    # logged in) and the `post_logout_redirect_uri`, which is the schools
    # landing page.
    #
    # NOTE that the post_logout_redirect_uri must be configured by the DfE
    # Sign-in team and what we supply must match what's configured
    def destroy
      id_token = session[:id_token]

      if id_token.nil?
        fail NoIDTokenError, 'No id_token present, cannot log out from DfE Sign-in'
      end

      session.clear
      redirect_to [end_session_endpoint, build_query(id_token)].join('?')
    end

  private

    def end_session_endpoint
      "https://#{get_oidc_client.host}/session/end"
    end

    def build_query(id_token)
      {
        id_token_hint: id_token,
        post_logout_redirect_uri: schools_url
      }.to_query
    end
  end
end
