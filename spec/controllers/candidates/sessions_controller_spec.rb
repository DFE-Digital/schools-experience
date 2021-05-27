require 'rails_helper'

RSpec.describe Candidates::SessionsController, type: :request do
  include ActiveJob::TestHelper

  include_context "stubbed out Gitis"

  describe "GET #new" do
    before { get candidates_signin_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    around { |example| perform_enqueued_jobs { example.run } }
    before { NotifyFakeClient.reset_deliveries! }

    let(:valid_creds) do
      {
        email: 'testy@mctest.com',
        firstname: 'testy',
        lastname: 'mctest',
        date_of_birth: 20.years.ago.to_date
      }
    end

    context "for known user" do
      let(:candidate) { create(:candidate) }
      let(:token) { create(:candidate_session_token, candidate: candidate) }

      before do
        expect_any_instance_of(Candidates::Session).to receive(:create_signin_token).and_return(token.token)
        post candidates_signin_path, params: { candidates_session: valid_creds }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to match('Verify your school experience sign in')
      end

      it "will send email with token link" do
        expect(NotifyFakeClient.deliveries.length).to eql(1)

        delivery = NotifyFakeClient.deliveries.first
        expect(delivery[:email_address]).to eql(valid_creds[:email])

        token = Candidates::SessionToken.reorder(:id).last.token
        expect(delivery[:personalisation][:confirmation_link]).to \
          match(%r{/signin/#{token}\z})
        expect(delivery[:personalisation][:confirmation_link]).to \
          match(candidates_signin_confirmation_url(token))
      end
    end

    context "for unknown user" do
      before do
        expect_any_instance_of(Candidates::Session).to receive(:create_signin_token).and_return(false)
        post candidates_signin_path, params: { candidates_session: valid_creds }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to match('Verify your school experience sign in')
      end

      it "will not send email with token link" do
        expect(NotifyFakeClient.deliveries.length).to eql(0)
      end
    end

    context 'with missing details' do
      let(:invalid_creds) { { candidates_session: { email: 'invalid' } } }
      before { post candidates_signin_path, params: invalid_creds }

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to match('Get school experience sign in')
      end

      it "will not send email with token link" do
        expect(NotifyFakeClient.deliveries.length).to eql(0)
      end
    end

    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"

      context "for known user" do
        include_context "api candidate matched back"

        let(:candidate) { create(:candidate) }

        before do
          post candidates_signin_path, params: { candidates_session: valid_creds }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
          expect(response.body).to match('Verify your school experience sign in')
        end
      end

      context "for unknown user" do
        include_context "api candidate not matched back"

        before do
          post candidates_signin_path, params: { candidates_session: valid_creds }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
          expect(response.body).to match('Verify your school experience sign in')
        end
      end

      context 'with missing details' do
        let(:invalid_creds) { { candidates_session: { email: 'invalid' } } }
        before { post candidates_signin_path, params: invalid_creds }

        it "returns http success" do
          expect(response).to have_http_status(:success)
          expect(response.body).to match('Get school experience sign in')
        end
      end
    end
  end

  describe "GET #update" do
    context "with valid token" do
      let(:token) { create(:candidate_session_token) }
      before { gitis_stubs.stub_contact_request(token.candidate.gitis_uuid) }
      before { get candidates_signin_confirmation_path(token) }

      it "redirects to dashboard" do
        expect(response).to redirect_to(candidates_dashboard_path)
      end
    end

    context "with expired token" do
      let(:token) { create(:candidate_session_token, :expired) }
      before { get candidates_signin_confirmation_path(token) }

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include("link has expired")
      end
    end
  end

  describe "PUT #update" do
    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"
      include_context "api correct verification code"

      let(:personal_info) { build(:personal_information) }
      let(:params) do
        {
          candidates_verification_code: {
            code: code,
            firstname: personal_info.first_name,
            lastname: personal_info.last_name,
            email: personal_info.email,
            date_of_birth: "2000-01-01",
          }
        }
      end
      let(:perform_request) { put candidates_signin_code_path, params: params }

      context "with a valid code" do
        before { perform_request }

        it "redirects to dashboard" do
          expect(response).to redirect_to(candidates_dashboard_path)
        end

        it "will create a confirmed candidate" do
          candidate = Bookings::Candidate.find_by(gitis_uuid: sign_up.candidate_id)
          expect(candidate).to be_confirmed
        end
      end

      context "with an invalid code" do
        include_context "api incorrect verification code"

        before { perform_request }

        it "will show error screen" do
          expect(response).to have_http_status(:success)
          expect(response.body).to include("Please enter the latest verification code sent to your email address")
        end
      end
    end
  end
end
