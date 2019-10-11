require 'rails_helper'

RSpec.describe Candidates::Registrations::SignInsController, type: :request do
  include ActiveJob::TestHelper
  let(:school_id) { 11048 }
  let!(:school) { create(:bookings_school, urn: school_id) }

  include_context 'fake gitis with known uuid'

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new(
      'urn' => school_id,
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
        get candidates_registration_verify_path(school_id, token)
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
        get candidates_registration_verify_path(school_id, token)
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

        get candidates_registration_verify_path(school_id, token)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end
    end

    context 'when having swapped device' do
      before do
        get candidates_registration_verify_path(school_id, token)
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
        get candidates_registration_verify_path(school_id, token)
      end

      it "will redirect_to ContactInformation step" do
        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end

      it "will have confirmed candidate" do
        expect(token.candidate.reload).to be_confirmed
      end
    end
  end

  describe 'POST #create' do
    include_context 'Stubbed current_registration'

    before do
      NotifyFakeClient.reset_deliveries!
      allow(queue_adapter).to receive(:perform_enqueued_jobs).and_return(true)
    end

    let!(:candidate) { create(:candidate, gitis_uuid: fake_gitis_uuid) }
    let(:token) { create(:candidate_session_token, candidate: candidate) }

    before do
      post candidates_school_registrations_sign_in_path(school_id)
    end

    it "will redirect to the show page" do
      expect(response).to \
        redirect_to candidates_school_registrations_sign_in_path(school_id)
    end

    it "will have created new token" do
      expect(token.candidate.reload.session_tokens.count).to eql(2)
    end

    it "sends a verification email" do
      expect(NotifyFakeClient.deliveries.length).to eql(1)

      delivery = NotifyFakeClient.deliveries.first
      expect(delivery[:email_address]).to \
        eql(registration_session.personal_information.email)

      expect(delivery[:personalisation][:verification_link]).to \
        match(%r{/candidates/verify/[0-9]+/[^/]{24}\z})
    end
  end
end
