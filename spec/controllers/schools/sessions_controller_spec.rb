require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  context '#create' do
    context 'redirection' do
      let(:return_url) { '/schools/dashboard' }

      let(:state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }
      let(:code) { 'OTA4MTU0ZTgtMjBhZC00YmNmLThmMmQtOGZiZDhmNTYxMTA2vLY8wh-MpR-WR3vsn4C2J_oBkN-KGjD9-XVcDFS8UyADwt5DrIrYe0Gjgsj2gpvAt5L2cka5n8ZZmiojr6zgWg' }
      let(:session_state) { '652b5afc63d7c4875c42de4231f66e4940226f840b2a7ea02441544751ea0a2a.h3bd7bc2438a84dc' }
      let(:access_token) { 'abc123' }

      let(:urn) { 123456 }

      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return(
            return_url: return_url,
            state: state
        )
      end

      before do
        stub_request(:post, "https://#{Rails.configuration.x.oidc_host}/token")
          .with(
            body: {
              'code'         => code,
              'grant_type'   => 'authorization_code',
              'redirect_uri' => "#{Rails.configuration.x.base_url}/auth/callback"
            },
            headers: {
              'Accept'        => '*/*',
              'Authorization' => 'Basic c2UtdGVzdDphYmMxMjM=',
              'Content-Type'  => 'application/x-www-form-urlencoded',
              'Date'          => /.*/,
              'User-Agent'    => /Rack::OAuth2/
            }
          )
          .to_return(
            status: 200,
            headers: {},
            body: {
              token_type: 'Bearer',
              access_token: access_token
            }.to_json
          )

        stub_request(:get, "https://#{Rails.configuration.x.oidc_host}/me")
          .with(
            headers: {
              'Accept'        => '*/*',
              'Authorization' => "Bearer #{access_token}",
              'Date'          => /.*/,
              'User-Agent'    => /OpenIDConnect::AccessToken/
            }
          )
          .to_return(
            status: 200,
            headers: {},
            body: {
              organisation: {
                urn: urn
              }
            }.to_json
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

      context 'errors' do
        context 'StateMissmatchError' do
          let(:bad_state) { 'aaaaaaaa-bbbb-1111-2222-333333333333' }
          let(:callback) { "/auth/callback?code=#{code}&state=#{bad_state}&session_state=#{session_state}" }
          after { get callback }

          specify 'should raise StateMissmatchError' do
            expect(Rails.logger).to receive(:error).with(/doesn't match session state/)
          end

          specify 'should redirect to an error page' do
            expect(response.status).to eql 302
          end
        end

        context 'AuthFailedError' do
          let(:code) { nil }
          after { get callback }

          specify 'should raise AuthFailedError' do
            expect(Rails.logger).to receive(:error).with(/Login failed/)
          end

          specify 'should redirect to an error page' do
            expect(response.status).to eql 302
          end
        end
      end
    end
  end

  context '#destroy' do
    include_context "logged in DfE user"
    subject! { delete schools_session_path }

    specify "should clear the session" do
      expect(session).to be_empty
    end

    specify "should redirect to the homepage" do
      expect(subject).to redirect_to(root_path)
    end
  end
end
