require 'rails_helper'
require_relative 'session_context'

describe Schools::DfeSessionsController, type: :request do
  describe '#destroy' do
    include_context "logged in DfE user"

    context 'when a session exists and there is an id_token' do
      let(:oidc_host) { 'some-oidc-host' }
      let(:id_token) { 'abcdefg123456' }

      before { get(root_path) }
      subject { delete(schools_dfe_session_path) }

      before do
        allow(OpenIDConnect::Client).to receive(:new)
          .and_return(OpenStruct.new(host: oidc_host))
      end

      before { session[:id_token] = id_token }

      specify 'should redirect to the OpenID Connect end session endpoint with the correct query params' do
        expect(subject).to redirect_to(
          "%<oidc_host>s?%<query>s" % {
            oidc_host: ['https://', oidc_host, '/session/end'].join,
            query: {
              id_token_hint: id_token,
              post_logout_redirect_uri: schools_url
            }.to_query
          }
        )
      end
    end

    context 'when a session exists but there is no id_token' do
      subject { delete schools_dfe_session_path }

      specify 'it should raise an NoIDTokenError' do
        expect { subject }.to raise_error(Schools::NoIDTokenError, 'No id_token present, cannot log out from DfE Sign-in')
      end
    end
  end
end
