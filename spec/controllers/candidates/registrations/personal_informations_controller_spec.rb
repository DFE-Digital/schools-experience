require 'rails_helper'

describe Candidates::Registrations::PersonalInformationsController, type: :request do
  include ActiveJob::TestHelper

  include_context 'Stubbed current_registration'

  let!(:other_school) { create(:bookings_school, urn: 10_020) }
  let!(:school) { create(:bookings_school, urn: 11_048) }

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new('urn' => '11048')
  end

  context 'without existing personal information in the session' do
    context '#new' do
      before do
        get '/candidates/schools/10020/registrations/personal_information/new'
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      let :personal_information_params do
        {
          candidates_registrations_personal_information: \
            personal_information.attributes
        }
      end

      around { |example| perform_enqueued_jobs { example.run } }
      before { NotifyFakeClient.reset_deliveries! }

      context 'invalid' do
        before do
          post \
            '/candidates/schools/10020/registrations/personal_information',
            params: personal_information_params
        end

        let :personal_information do
          Candidates::Registrations::PersonalInformation.new
        end

        it 'doesnt modify the session' do
          expect { registration_session.personal_information }.to raise_error \
            Candidates::Registrations::RegistrationSession::StepNotFound
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'valid and known to gitis' do
        include_context "api candidate matched back"

        let :personal_information do
          FactoryBot.build :personal_information
        end

        let(:token) { create(:candidate_session_token) }

        before do
          post \
            '/candidates/schools/10020/registrations/personal_information',
            params: personal_information_params
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/10020/registrations/sign_in'
        end
      end

      context 'valid but not known to gitis' do
        include_context "api candidate not matched back"

        let :personal_information do
          FactoryBot.build :personal_information, email: 'unknown@mctest.com'
        end

        before do
          post \
            '/candidates/schools/10020/registrations/personal_information',
            params: personal_information_params
        end

        it 'redirects to the contact information step' do
          expect(response).to redirect_to \
            '/candidates/schools/10020/registrations/contact_information/new'
        end
      end

      context 'already signed in' do
        include_context 'candidate signin'

        let :registration_session do
          Candidates::Registrations::GitisRegistrationSession.new({ 'urn' => '10020' }, gitis_contact)
        end

        let :personal_information do
          FactoryBot.build :personal_information, read_only: true
        end

        before do
          post \
            '/candidates/schools/10020/registrations/personal_information',
            params: personal_information_params
        end

        it 'leaves the personal information with GiTiS details' do
          expect(registration_session.personal_information.first_name).to \
            eq gitis_contact.first_name

          expect(registration_session.personal_information.last_name).to \
            eq gitis_contact.last_name

          expect(registration_session.personal_information.date_of_birth).to \
            eq gitis_contact.date_of_birth
        end

        it "leaves the email address matching the GiTiS contact" do
          expect(registration_session.personal_information.email).to \
            eq gitis_contact.email
        end

        it "does not send a verification email" do
          expect(NotifyFakeClient.deliveries.length).to eql(0)
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/10020/registrations/contact_information/new'
        end
      end
    end
  end

  context 'with existing personal information in gitis' do
    include_context 'candidate signin'

    let :registration_session do
      Candidates::Registrations::GitisRegistrationSession.new({ 'urn' => '10020' }, gitis_contact)
    end

    context '#new' do
      before do
        get '/candidates/schools/10020/registrations/personal_information/new'
      end

      it 'populates the form with the values from gitis' do
        expect(assigns(:personal_information)).to have_attributes \
          first_name: gitis_contact.first_name,
          email: gitis_contact.email
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context 'with existing personal information in session' do
    let :existing_personal_information do
      FactoryBot.build :personal_information, urn: 10_020
    end

    let :registration_session do
      Candidates::Registrations::RegistrationSession.new('urn' => '10020')
    end

    before do
      registration_session.save existing_personal_information
    end

    context '#new' do
      before do
        get '/candidates/schools/10020/registrations/personal_information/new'
      end

      it 'populates the form with the values from the session' do
        expect(assigns(:personal_information)).to \
          eq_model existing_personal_information
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#edit' do
      before do
        get '/candidates/schools/10020/registrations/personal_information/edit'
      end

      it 'populates the form with the values from the session' do
        expect(assigns(:personal_information)).to eq existing_personal_information
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      let :personal_information_params do
        {
          candidates_registrations_personal_information: \
            personal_information.attributes
        }
      end

      before do
        patch \
          '/candidates/schools/10020/registrations/personal_information',
          params: personal_information_params
      end

      context 'invalid' do
        let :personal_information do
          Candidates::Registrations::PersonalInformation.new
        end

        it 'doesnt modify the session' do
          expect(registration_session.personal_information).not_to \
            eq_model personal_information
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :personal_information do
          FactoryBot.build :personal_information, email: 'new-email@test.com', urn: 10_020
        end

        it 'updates the session' do
          expect(registration_session.personal_information).to \
            eq_model personal_information
        end

        it 'redirects to application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/10020/registrations/application_preview'
        end
      end
    end
  end
end
