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
    include_context "Stubbed current_registration"
    include_context "api correct verification code for personal info"

    let(:personal_info) { registration_session.personal_information }
    let(:params) do
      {
        candidates_verification_code: {
          code: code,
          firstname: "Testy",
          lastname: "McTest",
          email: "testy@mctest.com",
          date_of_birth: "1980-01-01",
        }
      }
    end
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

      let(:sign_up) { build(:api_schools_experience_sign_up, candidate_id: gitis_contact_attrs[:candidate_id]) }

      it "will not create another Candidate and redirect_to ConfirmationInformation step" do
        expect { perform_request }.not_to(change { Bookings::Candidate.count })

        expect(response).to \
          redirect_to new_candidates_school_registrations_contact_information_path(school_id)
      end
    end

    context "with valid code but invalid Gitis data" do
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

  describe 'POST #create' do
    include_context 'Stubbed current_registration'
    include_context "api candidate matched back"

    let!(:candidate) { create(:candidate, gitis_uuid: fake_gitis_uuid) }

    let(:perform_request) do
      perform_enqueued_jobs do
        post candidates_school_registrations_sign_in_path(school_id)
      end
    end

    it "will issue a verification code and redirect to the show page" do
      perform_request

      expect(response).to \
        redirect_to candidates_school_registrations_sign_in_path(school_id)
    end
  end
end
