require 'rails_helper'

RSpec.describe Candidates::SessionsController, type: :request do
  include ActiveJob::TestHelper

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
        lastname: 'mctest'
      }
    end

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

  describe "PUT #update" do
    include_context "api correct verification code for personal info"

    let(:personal_info) { build(:personal_information) }
    let(:params) do
      {
        candidates_verification_code: {
          code: code,
          firstname: personal_info.first_name,
          lastname: personal_info.last_name,
          email: personal_info.email
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
