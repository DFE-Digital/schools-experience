require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  context '#create' do
    let(:return_url) { '/schools/dashboard' }
    let(:state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }

    context 'when the user is not yet signed in' do
      let(:code) { 'OTA4MTU0ZTgtMjBhZC00YmNmLThmMmQtOGZiZDhmNTYxMTA2vLY8wh-MpR-WR3vsn4C2J_oBkN-KGjD9-XVcDFS8UyADwt5DrIrYe0Gjgsj2gpvAt5L2cka5n8ZZmiojr6zgWg' }
      let(:session_state) { '652b5afc63d7c4875c42de4231f66e4940226f840b2a7ea02441544751ea0a2a.h3bd7bc2438a84dc' }
      let(:access_token) { 'abc123' }

      let(:urn) { 123456 }
      let(:school_name) { "Springfield Elementary" }

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
                urn: urn,
                name: school_name
              }
            }.to_json
          )
      end

      let(:callback) { "/auth/callback?code=#{code}&state=#{state}&session_state=#{session_state}" }

      subject! { get callback }

      specify 'should redirect to the return url' do
        expect(response.body).to redirect_to(return_url)
      end

      specify 'should save the URN in the session' do
        expect(session[:urn]).to eql(urn)
      end

      specify 'should save the school name in the session' do
        expect(session[:school_name]).to eql(school_name)
      end

      specify 'should save the current user in the session' do
        expect(session[:current_user]).to be_a(OpenIDConnect::ResponseObject::UserInfo)
      end

      context 'errors' do
        context 'Errors returned by DfE Sign-in' do
          let(:error) { 'baderror' }
          let(:callback) { "/auth/callback?error=#{error}" }

          after { get callback }

          specify 'should raise an AuthFailed error' do
            expect(response.status).to eql 302
            expect(response.redirect_url).to end_with('schools/errors/auth_failed')
          end

          specify 'should write a message to the log' do
            expect(Rails.logger).to receive(:error).with(/DfE Sign-in error response/)
          end
        end

        context 'StateMismatchError' do
          {
            'aaaaaaaa-bbbb-1111-2222-333333333333' => 'not-matching',
            '' => 'empty',
            nil => 'missing'
          }.each do |bad_state, description|
            context description do
              let(:callback) { "/auth/callback?code=#{code}&state=#{bad_state}&session_state=#{session_state}" }
              after { get callback }

              specify 'should raise StateMismatchError' do
                expect(Rails.logger).to receive(:error).with(/doesn't match session state/)
              end

              specify 'should redirect to an error page' do
                expect(response.status).to eql 302
                expect(response.redirect_url).to end_with('schools/errors/auth_failed')
              end
            end
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
            expect(response.redirect_url).to end_with('schools/errors/auth_failed')
          end
        end
      end
    end

    context 'when the user is already logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:session).and_return(
            return_url: return_url,
            state: state,
            current_user: { name: 'Milhouse' }
        )
      end

      subject { get auth_callback_path }

      specify 'should redirect to the dashboard' do
        expect(subject).to redirect_to(schools_dashboard_path)
      end
    end
  end

  describe '#logout' do
    include_context "logged in DfE user"

    context 'when a session exists and there is an id_token' do
      let(:oidc_host) { 'some-oidc-host' }
      let(:id_token) { 'abcdefg123456' }

      before { get(root_path) }
      subject { get(logout_schools_session_path) }

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
      subject { get(logout_schools_session_path) }

      before { allow(Rails.logger).to receive(:error).and_return(true) }

      specify 'it should write a message to the error log' do
        subject
        expect(Rails.logger).to have_received(:error).with(/No id_token present/)
      end

      specify 'it should redirect directly to the schools path' do
        expect(subject).to redirect_to(schools_path)
      end
    end
  end
end
