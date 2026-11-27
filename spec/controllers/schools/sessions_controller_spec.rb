require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  shared_context 'when handling an OIDC callback' do
    include_context "with a session double"

    let(:code) { 'OTA4MTU0ZTgtMjBhZC00YmNmLThmMmQtOGZiZDhmNTYxMTA2vLY8wh-MpR-WR3vsn4C2J_oBkN-KGjD9-XVcDFS8UyADwt5DrIrYe0Gjgsj2gpvAt5L2cka5n8ZZmiojr6zgWg' }
    let(:session_state) { '652b5afc63d7c4875c42de4231f66e4940226f840b2a7ea02441544751ea0a2a.h3bd7bc2438a84dc' }
    let(:access_token) { 'abc123' }

    let(:urn) { 123_456 }
    let(:school_name) { "Springfield Elementary" }

    let(:session_hash) { {} }

    before do
      session_hash[:return_url] = return_url
      session_hash[:state] = state
    end

    before do
      stub_request(:post, "https://#{Rails.configuration.x.oidc_host}/token")
        .with(
          body: {
            'code' => code,
            'grant_type' => 'authorization_code',
            'redirect_uri' => "#{Rails.configuration.x.base_url}/auth/callback"
          },
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Basic c2UtdGVzdDphYmMxMjM=',
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Date' => /.*/,
            'User-Agent' => /Rack::OAuth2/
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
            'Accept' => '*/*',
            'Authorization' => "Bearer #{access_token}",
            'Date' => /.*/,
            'User-Agent' => /OpenIDConnect::AccessToken/
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
  end

  describe '#create' do
    let(:return_url) { '/schools/dashboard' }
    let(:state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }

    context 'when the user is not yet signed in' do
      include_context 'when handling an OIDC callback'

      subject! { get callback } # rubocop:disable RSpec/LeadingSubject -- Request must run after OIDC setup.

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

      context 'when errors' do
        before { allow(Rails.logger).to receive(:error) }

        context 'when errors returned by DfE Sign-in' do
          let(:error) { 'baderror' }
          let(:callback) { "/auth/callback?error=#{error}" }

          before { get callback }

          specify 'should raise an AuthFailed error' do
            expect(response.status).to be 302
            expect(response.redirect_url).to end_with('schools/errors/auth_failed')
          end

          specify 'should write a message to the log' do
            expect(Rails.logger).to have_received(:error).with(/DfE Sign-in error response/)
          end
        end

        context 'when stateMismatchError' do
          {
            'aaaaaaaa-bbbb-1111-2222-333333333333' => 'not-matching',
            '' => 'empty',
            nil => 'missing'
          }.each do |bad_state, description|
            context description do
              let(:callback) { "/auth/callback?code=#{code}&state=#{bad_state}&session_state=#{session_state}" }

              before { get callback }

              specify 'should raise StateMismatchError' do
                expect(Rails.logger).to have_received(:error).with(/doesn't match session state/)
              end

              specify 'should redirect to an error page' do
                expect(response.status).to be 302
                expect(response.redirect_url).to end_with('schools/errors/auth_failed')
              end
            end
          end
        end

        context 'when authFailedError' do
          let(:code) { nil }

          before { get callback }

          specify 'should raise AuthFailedError' do
            expect(Rails.logger).to have_received(:error).with(/Login failed/)
          end

          specify 'should redirect to an error page' do
            expect(response.status).to be 302
            expect(response.redirect_url).to end_with('schools/errors/auth_failed')
          end
        end
      end
    end

    describe 'role checking' do
      include_context 'when handling an OIDC callback'

      let(:signin_role_check_response) { false }

      before do
        allow(Schools::DFESignInAPI::Client).to receive_messages(enabled?: true, role_check_enabled?: true)
      end

      subject! { get callback } # rubocop:disable RSpec/LeadingSubject -- Request must run after OIDC and role setup.

      specify 'should redirect to the insufficient privileges error page' do
        expect(subject).to redirect_to(schools_errors_insufficient_privileges_path)
      end

      specify 'should not assign current_user' do
        expect(request.session[:current_user]).to be_nil
      end
    end

    context 'when the user is already logged in' do
      subject { get auth_callback_path }

      include_context 'when handling an OIDC callback'

      before do
        session_hash[:return_url] = return_url
        session_hash[:state] = state
        session_hash[:current_user] = OpenIDConnect::ResponseObject::UserInfo.new(sub: "abc1243", name: 'Milhouse')
      end

      specify 'should redirect to the dashboard' do
        expect(subject).to redirect_to(schools_dashboard_path)
      end
    end

    context 'when the session has timed out' do
      subject { get expired_auth_callback_path }

      let(:message) { 'sessionexpired' }
      let(:expired_auth_callback_path) { "/auth/callback?error=#{message}" }

      before do
        allow(Rails.logger).to receive(:warn).and_return(true)
      end

      specify 'should log that the session has expired' do
        subject
        expect(Rails.logger).to have_received(:warn).with('DfE Sign-in session expiry error, restarting login process')
      end

      specify 'should redirect to the school dashboard' do
        expect(subject).to redirect_to(schools_dashboard_path)
      end
    end

    context 'when the saved application session state is missing' do
      subject(:call_callback) { get callback }

      include_context 'when handling an OIDC callback'

      let(:return_url) { '/schools/dashboard' }
      let(:callback_state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }
      let(:callback) { "/auth/callback?code=#{code}&state=#{callback_state}&session_state=#{session_state}" }
      let(:saved_state) { nil }

      before do
        session_hash[:state] = saved_state
        allow(Rails.logger).to receive(:warn).and_call_original
        allow(Rails.logger).to receive(:error).and_call_original
      end

      shared_examples 'a recovery that discards the callback' do
        specify 'redirects to the dashboard so sign-in restarts' do
          call_callback
          expect(response).to redirect_to(schools_dashboard_path)
        end

        specify 'logs a warning without raw state, code or params' do
          call_callback
          expect(Rails.logger).to have_received(:warn).with('Saved DfE Sign-in state missing from session, restarting login process')
          expect(Rails.logger).not_to have_received(:error)
        end

        specify 'does not capture an exception in Sentry' do
          allow(Sentry).to receive(:capture_exception)
          call_callback
          expect(Sentry).not_to have_received(:capture_exception)
        end

        specify 'does not exchange the code or fetch userinfo' do
          call_callback
          expect(WebMock).not_to have_requested(:post, "https://#{Rails.configuration.x.oidc_host}/token")
          expect(WebMock).not_to have_requested(:get, "https://#{Rails.configuration.x.oidc_host}/me")
        end

        specify 'does not populate authenticated session data' do
          call_callback
          expect(session[:current_user]).to be_nil
          expect(session[:urn]).to be_nil
          expect(session[:id_token]).to be_nil
        end
      end

      context 'when the saved state is absent and the callback has a state' do
        let(:saved_state) { nil }

        it_behaves_like 'a recovery that discards the callback'
      end

      context 'when the saved state is an empty string' do
        let(:saved_state) { '' }

        it_behaves_like 'a recovery that discards the callback'
      end

      context 'when the saved state is blank and the callback has no state' do
        let(:saved_state) { '' }
        let(:callback) { "/auth/callback?code=#{code}&session_state=#{session_state}" }

        it_behaves_like 'a recovery that discards the callback'
      end

      context 'when both the saved and callback states are blank' do
        let(:saved_state) { '' }
        let(:callback_state) { '' }

        it_behaves_like 'a recovery that discards the callback'
      end

      context 'when the saved state is absent and the callback state is absent' do
        let(:saved_state) { nil }
        let(:callback) { "/auth/callback?code=#{code}&session_state=#{session_state}" }

        it_behaves_like 'a recovery that discards the callback'
      end

      context 'when the recovery redirect is followed with a usable session' do
        let(:saved_state) { nil }

        specify 'starts sign-in again with a nonblank state and nonce' do
          call_callback
          get schools_dashboard_path

          authorization_uri = URI.parse(response.location)
          query = Rack::Utils.parse_query(authorization_uri.query)

          expect(authorization_uri.host).to eql(Rails.configuration.x.oidc_host)
          expect(authorization_uri.path).to eql('/auth')
          expect(query['state']).to be_present
          expect(query['state']).to eql(session_hash[:state])
          expect(query['nonce']).to be_present
          expect(query['nonce']).to eql(session_hash[:nonce])
        end
      end
    end

    context 'when the saved application session state is present' do
      subject(:call_callback) { get callback }

      include_context 'when handling an OIDC callback'

      let(:return_url) { '/schools/dashboard' }
      let(:saved_state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }
      let(:state) { saved_state }

      before do
        session_hash[:state] = saved_state
        allow(Rails.logger).to receive(:error).and_call_original
      end

      {
        'missing' => nil,
        'blank' => '',
        'different' => 'aaaaaaaa-bbbb-1111-2222-333333333333'
      }.each do |description, callback_state|
        context "when the callback state is #{description}" do
          let(:callback) { "/auth/callback?code=#{code}&state=#{callback_state}&session_state=#{session_state}" }

          specify 'redirects to the auth failed page' do
            call_callback
            expect(response).to redirect_to(schools_errors_auth_failed_path)
          end

          specify 'captures a StateMismatchError in Sentry' do
            allow(Sentry).to receive(:capture_exception)
            call_callback
            expect(Sentry).to have_received(:capture_exception).with(an_instance_of(Schools::StateMismatchError))
          end

          specify 'does not exchange the code' do
            allow(Sentry).to receive(:capture_exception)
            call_callback
            expect(WebMock).not_to have_requested(:post, "https://#{Rails.configuration.x.oidc_host}/token")
          end

          specify 'does not populate authenticated session data' do
            allow(Sentry).to receive(:capture_exception)
            call_callback
            expect(session[:current_user]).to be_nil
          end
        end
      end
    end
  end

  describe '#logout' do
    include_context "when a DfE user is logged in"

    context 'when a session exists and there is an id_token' do
      subject { get(logout_schools_session_path) }

      let(:oidc_host) { 'some-oidc-host' }
      let(:id_token) { 'abcdefg123456' }

      before do
        get(root_path)
        allow(OpenIDConnect::Client).to receive(:new)
                  .and_return(OpenStruct.new(host: oidc_host))
        session[:id_token] = id_token
      end

      specify 'should redirect to the OpenID Connect end session endpoint with the correct query params' do
        expect(subject).to redirect_to(
          sprintf("%<oidc_host>s?%<query>s", oidc_host: ['https://', oidc_host, '/session/end'].join, query: {
            id_token_hint: id_token,
            post_logout_redirect_uri: schools_url
          }.to_query)
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
