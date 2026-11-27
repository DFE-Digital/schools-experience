require 'rails_helper'

RSpec.describe Candidates::SessionsController, type: :request do
  include ActiveJob::TestHelper

  describe "GET #new" do
    before { get candidates_signin_path }

    it "redirects the user to /candidates" do
      expect(response).to have_http_status(:redirect)
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

    context "when the user is known" do
      include_context "when the API candidate matches back"

      let(:candidate) { create(:candidate) }

      before do
        post candidates_signin_path, params: { candidates_session: valid_creds }
      end

      it "redirects the user to /candidates" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the user is unknown" do
      include_context "when the API candidate does not match back"

      context "when less than 3 failed attempts" do
        before do
          2.times do
            post candidates_signin_path, params: { candidates_session: valid_creds }
          end
        end

        it "redirects the user to /candidates" do
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when there have been more than 2 failed attempts" do
        before do
          3.times do
            post candidates_signin_path, params: { candidates_session: valid_creds }
          end
        end

        it "redirects the user to /candidates" do
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'with missing details' do
      let(:invalid_creds) { { candidates_session: { email: 'invalid' } } }

      before { post candidates_signin_path, params: invalid_creds }

      it "returns http redirect to /candidates" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PUT #update" do
    include_context "when the API returns a correct verification code for personal information"

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

      it "creates a confirmed candidate" do
        candidate = Bookings::Candidate.find_by(gitis_uuid: sign_up.candidate_id)
        expect(candidate).to be_confirmed
      end
    end

    context "with an invalid code" do
      include_context "when the API returns an incorrect verification code"

      before { perform_request }

      it "shows error screen" do
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Please enter the latest verification code sent to your email address")
      end
    end
  end

  describe "sign_out" do
    include_context "when the API candidate matches back"

    before { get candidates_signout_path }

    it "empties the gitis_contact session and redirects to the dashboard sign in" do
      expect(session[:gitis_contact]).to be_nil
      expect(response).to redirect_to(candidates_dashboard_path)
    end
  end
end
