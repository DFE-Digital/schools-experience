require 'rails_helper'

describe Candidates::Registrations::PersonalInformationsController, type: :request do
  include_context 'Stubbed current_registration'
  include_context 'fake gitis'

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new({})
  end

  context 'without existing personal information in the session' do
    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/personal_information/new'
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

      context 'invalid' do
        before do
          post \
            '/candidates/schools/11048/registrations/personal_information',
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
        let :personal_information do
          FactoryBot.build :personal_information
        end

        let(:token) { create(:candidate_session_token) }

        before do
          post \
            '/candidates/schools/11048/registrations/personal_information',
            params: personal_information_params
        end

        it 'updates the session with the new details' do
          expect(registration_session.personal_information).to \
            eq_model personal_information
        end

        it "sends a sign in email"

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/sign_ins'
        end
      end

      context 'valid but not known to gitis' do
        let :personal_information do
          FactoryBot.build :personal_information, email: 'unknown@mctest.com'
        end

        before do
          post \
            '/candidates/schools/11048/registrations/personal_information',
            params: personal_information_params
        end

        it 'updates the session with the new details' do
          expect(registration_session.personal_information).to \
            eq_model personal_information
        end

        it 'does not send sign in email'

        it 'redirects to the contact information step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/contact_information/new'
        end
      end

      context 'already signed in' do
        let :personal_information do
          FactoryBot.build :personal_information
        end

        let(:token) { create(:candidate_session_token) }
        let(:contact_attributes) do
          token.candidate.fetch_gitis_contact(fake_gitis).attributes
        end

        before do
          allow_any_instance_of(ActionDispatch::Request::Session).to \
            receive(:[]).with(:gitis_contact).and_return(contact_attributes)

          post \
            '/candidates/schools/11048/registrations/personal_information',
            params: personal_information_params
        end

        it 'updates the session with the new details' do
          expect(registration_session.personal_information).to \
            eq_model personal_information
        end

        it "does not send a sign in email"

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/contact_information/new'
        end
      end
    end
  end

  context 'with existing personal information in session' do
    let :existing_personal_information do
      FactoryBot.build :personal_information
    end

    before do
      registration_session.save existing_personal_information
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/personal_information/new'
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
        get '/candidates/schools/11048/registrations/personal_information/edit'
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
          '/candidates/schools/11048/registrations/personal_information',
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
          FactoryBot.build :personal_information, email: 'new-email@test.com'
        end

        it 'updates the session' do
          expect(registration_session.personal_information).to \
            eq_model personal_information
        end

        it 'redirects to application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
