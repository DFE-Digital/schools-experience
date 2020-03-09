module DFEAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user

  protected

    def current_user
      @current_user ||= session[:current_user]
    end
    alias_method :set_current_user, :current_user
    helper_method :current_user

    def user_signed_in?
      current_user.present?
    end

    def require_auth
      return if user_signed_in?

      client = get_oidc_client

      session[:state] ||= SecureRandom.uuid # You can specify or pass in your own state here
      session[:nonce] ||= SecureRandom.hex(16) # You should store this and validate it on return.
      session[:return_url] = request.original_url
      redirect_to client.authorization_uri(
        state: session[:state],
        nonce: session[:nonce],
        scope: %i(profile organisation)
      )
    end

    helper_method :has_other_schools?
  end

private

  def get_oidc_client
    OpenIDConnect::Client.new(
      identifier: Rails.configuration.x.oidc_client_id,
      secret: Rails.configuration.x.oidc_client_secret,
      redirect_uri: "#{Rails.configuration.x.base_url}/auth/callback",
      host: Rails.configuration.x.oidc_host,
      authorization_endpoint: '/auth',
      token_endpoint: '/token',
      userinfo_endpoint: '/me'
    )
  end

  def school_urns(reload = false)
    session[:urns] = nil if reload

    session[:urns] ||= retrieve_school_urns.freeze # should only be replaced, not changed immutable
  end

  def retrieve_school_urns
    Schools::DFESignInAPI::Organisations
      .new(current_user.sub)
      .urns
  end

  def other_school_urns
    school_urns.without(current_school.urn)
  end

  # if the DfE Sign-in api client isn't configured assume users
  # may have other schools
  def has_other_schools?
    return true unless Schools::DFESignInAPI::Client.enabled?

    other_school_urns.any?
  end
end
