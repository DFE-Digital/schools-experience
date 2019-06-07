require 'rails_helper'

RSpec.describe Candidates::SessionsController, type: :request do
  include_context "stubbed out Gitis"

  describe "GET #new" do
    before { get candidates_signin_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
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

      before do
        expect_any_instance_of(Candidates::Session).to receive(:signin).and_return(candidate)
        post candidates_signin_path, params: { candidates_session: valid_creds }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
        expect(response.body).to match('Verify your school experience sign in')
      end
    end

    context "for unknown user" do
      before do
        expect_any_instance_of(Candidates::Session).to receive(:signin).and_return(false)
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
end
