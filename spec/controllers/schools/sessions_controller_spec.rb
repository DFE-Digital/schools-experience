require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  context '#create' do
    context 'redirection' do
      let(:return_url) { '/schools/dashboard' }

      let(:state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }
      let(:code) { 'OTA4MTU0ZTgtMjBhZC00YmNmLThmMmQtOGZiZDhmNTYxMTA2vLY8wh-MpR-WR3vsn4C2J_oBkN-KGjD9-XVcDFS8UyADwt5DrIrYe0Gjgsj2gpvAt5L2cka5n8ZZmiojr6zgWg' }
      let(:session_state) { '652b5afc63d7c4875c42de4231f66e4940226f840b2a7ea02441544751ea0a2a.h3bd7bc2438a84dc' }

      let(:urn) { 123456 }

      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return(
            return_url: return_url,
            state: state
        )
      end

      before do
        stub_request(:post, "https://some-oidc-host.education.gov.uk/token")
          .with(
            body: {
              "code"         => code,
              "grant_type"   => "authorization_code",
              "redirect_uri" => "https://some-host/auth/callback"
            },
            headers: {
              'Accept'        => '*/*',
              'Authorization' => 'Basic c2UtdGVzdDphYmMxMjM=',
              'Content-Type'  => 'application/x-www-form-urlencoded',
              'Date'          => /.*/,
              'User-Agent'    => 'Rack::OAuth2 (1.9.3) (2.8.3, ruby 2.5.5 (2019-03-15))'
            }
          )
          .to_return(
            status: 200,
            body: {
              token_type: "bearer",
              access_token: 'abc123'
            }.to_json,
            headers: {}
          )

        stub_request(:get, "https://some-oidc-host.education.gov.uk/me")
          .with(
            headers: {
              'Accept'        => '*/*',
              'Authorization' => 'Bearer abc123',
              'Date'          => /.*/,
              'User-Agent'    => 'OpenIDConnect::AccessToken (1.9.3) (2.8.3, ruby 2.5.5 (2019-03-15))'
            }
          )
          .to_return(
            status: 200,
            body: {
              organisation: {
                urn: urn
              }
            }.to_json,
            headers: {}
         )
      end

      let(:callback) { "/auth/callback?code=#{code}&state=#{state}&session_state=#{session_state}" }

      subject! { get callback }

      specify 'should do the thing' do
        expect(response.body).to redirect_to(return_url)
      end

      specify 'should save the URN in the session' do
        expect(session[:urn]).to eql(urn)
      end

      specify 'should save the current user in the session' do
        expect(session[:current_user]).to be_a(OpenIDConnect::ResponseObject::UserInfo)
      end
    end
  end

  context '#destroy' do
    include_context "logged in DfE user"
    subject { delete schools_session_path }

    specify "should clear the session" do
      subject
      expect(session).to be_empty
    end

    specify "should redirect to the homepage" do
      expect(subject).to redirect_to(root_path)
    end
  end
end
