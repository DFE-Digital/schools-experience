require 'rails_helper'

RSpec.describe Candidates::Registrations::SignInsController, type: :request do
  include ActiveJob::TestHelper
  let(:school_id) { 11_048 }
  let!(:school) { create(:bookings_school, urn: school_id) }

  include_context 'fake gitis with known uuid'

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new(
      'urn' => school_id,
      'uuid' => '123abc',
      Candidates::Registrations::PersonalInformation.model_name.param_key => \
        {
          'first_name' => 'Testy',
          'last_name' => 'McTest',
          'email' => 'testy@mctest.com',
          'date_of_birth' => Date.parse('1980-01-01')
        }
    )
  end

  describe 'GET #show' do
    include_context 'Stubbed current_registration'

    before { get candidates_school_registrations_sign_in_path(school_id) }

    it "should return HTTP success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #update' do
    let(:token) { create(:candidate_session_token) }
    let(:personal_info) { registration_session.personal_information }

    context 'with valid token' do
      include_context 'Stubbed current_registration'

      before do
        get candidates_registration_verify_path(school_id, token, registration_session.uuid)
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
      include_context 'Stubbed current_registration'

      before do
        expect(Candidates::Session).to receive(:signin!).and_return(nil)
        get candidates_registration_verify_path(school_id, token, registration_session.uuid)
      end

      it "will show error screen" do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when already signed in' do
      include_context 'Stubbed current_registration'
      include_context 'candidate signin'

      before do
        expect_any_instance_of(described_class).to \
          receive(:delete_registration_sessions!)

        get candidates_registration_verify_path(school_id, token, registration_session.uuid)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end
    end

    context 'when having swapped device' do
      before do
        get candidates_registration_verify_path(school_id, token, registration_session.uuid)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end

      it "will have confirmed candidate" do
        expect(token.candidate.reload).to be_confirmed
      end
    end

    context 'with valid token but invalid Gitis data' do
      include_context 'candidate signin'
      let(:gitis_contact_attrs) do
        attributes_for(:gitis_contact, :persisted, birthdate: nil)
      end

      before do
        get candidates_registration_verify_path(school_id, token, registration_session.uuid)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end

      it "will have confirmed candidate" do
        expect(token.candidate.reload).to be_confirmed
      end
    end

    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"
      include_context "Stubbed current_registration"
      include_context "api correct verification code"

      let(:params) { { candidates_verification_code: { code: code } } }
      let(:perform_request) { put candidates_registration_verify_code_path(school_id), params: params }

      context "with a valid code" do
        before { perform_request }

        it "will redirect_to ContactInformation step" do
          expect(response).to \
            redirect_to new_candidates_school_registrations_contact_information_path(school_id)
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

      context "when already signed in" do
        include_context "candidate signin"

        before do
          expect_any_instance_of(described_class).to \
            receive(:delete_registration_sessions!)
        end

        it "will redirect_to ContactInformation step" do
          perform_request

          expect(response).to \
            redirect_to new_candidates_school_registrations_contact_information_path(school_id)
        end
      end

      context "when the Candidate already exists" do
        include_context "candidate signin"

        let(:sign_up) { build(:api_schools_experience_sign_up, candidate_id: gitis_contact_attrs[:contactid]) }

        it "will not create another Candidate and redirect_to ConfirmationInformation step" do
          expect { perform_request }.not_to(change { Bookings::Candidate.count })

          expect(response).to \
            redirect_to new_candidates_school_registrations_contact_information_path(school_id)
        end
      end

      context "with valid token but invalid Gitis data" do
        let(:sign_up) { build(:api_schools_experience_sign_up, date_of_birth: nil) }

        before { perform_request }

        it "will redirect_to ContactInformation step" do
          expect(response).to \
            redirect_to new_candidates_school_registrations_contact_information_path(school_id)
        end

        it "will have confirmed candidate" do
          candidate = Bookings::Candidate.find_by(gitis_uuid: sign_up.candidate_id)
          expect(candidate).to be_confirmed
        end
      end
    end
  end

  describe 'POST #create' do
    include_context 'Stubbed current_registration'

    before { NotifyFakeClient.reset_deliveries! }

    let!(:candidate) { create(:candidate, gitis_uuid: fake_gitis_uuid) }
    let(:token) { create(:candidate_session_token, candidate: candidate) }

    let(:perform_request) do
      perform_enqueued_jobs do
        post candidates_school_registrations_sign_in_path(school_id)
      end
    end

    it "will redirect to the show page" do
      perform_request
      expect(response).to \
        redirect_to candidates_school_registrations_sign_in_path(school_id)
    end

    it "will have created new token" do
      perform_request
      expect(token.candidate.reload.session_tokens.count).to eql(2)
    end

    it "sends a verification email" do
      perform_request
      expect(NotifyFakeClient.deliveries.length).to eql(1)

      delivery = NotifyFakeClient.deliveries.first
      expect(delivery[:email_address]).to \
        eql(registration_session.personal_information.email)

      expect(delivery[:personalisation][:verification_link]).to \
        match(%r{/candidates/verify/[0-9]+/[^/]{24}/#{registration_session.uuid}\z})
    end

    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"
      include_context "api candidate matched back"

      it "will issue a verification code and redirect to the show page" do
        perform_request

        expect(response).to \
          redirect_to candidates_school_registrations_sign_in_path(school_id)
      end
    end
  end
end
