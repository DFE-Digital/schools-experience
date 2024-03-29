module DFEAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user

  protected

    def current_user
      @current_user ||= (User.exchange(session[:current_user]) if session[:current_user].present?)
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
        scope: oidc_auth_scope
      ), allow_other_host: true
    end

    helper_method :has_other_schools?
  end

private

  def oidc_auth_scope
    if Schools::ChangeSchool.allow_school_change_in_app?
      %i[profile]
    else
      %i[profile organisation]
    end
  end

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

  def school_urns(reload: false)
    if Schools::DFESignInAPI::Client.enabled?
      school_uuids(reload: reload).values
    else
      Array.wrap current_urn
    end
  end

  def school_uuids(reload: false)
    session[:uuid_map] = nil if reload

    session[:uuid_map] ||= retrieve_school_uuids.freeze
  end

  def retrieve_school_uuids
    Schools::DFESignInAPI::RoleCheckedOrganisations
      .new(current_user.sub)
      .organisation_uuid_pairs
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
