require 'rails_helper'

RSpec.describe Candidates::Registrations::SignInsController, type: :request do
  let(:school_id) { 11048 }
  include_context 'Stubbed current_registration'
  include_context "stubbed out Gitis"

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new(
      Candidates::Registrations::PersonalInformation.model_name.param_key => \
        { 'email' => 'testy@mctest.com' }
    )
  end

  describe 'GET #index' do
    before { get candidates_school_registrations_sign_ins_path(school_id) }

    it "should return HTTP success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #update' do
    let(:token) { create(:candidate_session_token) }

    context 'with valid token' do
      before do
        gitis_stubs.stub_contact_request(token.candidate.gitis_uuid)
        get candidates_school_registrations_sign_in_path(school_id, token)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end

      it "will have confirmed candidate" do
        expect(token.candidate.reload).to be_confirmed
      end
    end

    context 'with invalid token' do
      before do
        expect(Candidates::Session).to receive(:signin!).and_return(nil)
        get candidates_school_registrations_sign_in_path(school_id, token)
      end

      it "will show error screen" do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create' do
    let(:token) { create(:candidate_session_token) }
    before { post candidates_school_registrations_sign_ins_path(school_id) }

    it "will redirect to the index page" do
      pending "implementation"
      expect(response).to \
        redirect_to candidates_school_registrations_sign_ins_path(school_id)
    end

    it "will have created new token" do
      pending "implementation"
      expect(token.candidate.reload.session_tokens.count).to eql(2)
    end
  end
end
