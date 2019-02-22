require 'rails_helper'

describe Candidates::Registrations::ContactInformationsController, type: :request do
  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      contact_information: existing_contact_information,
      save: true
  end

  before do
    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  let :contact_information do
    FactoryBot.build :contact_information
  end

  context 'without existing contact information in the session' do
    let :existing_contact_information do
      nil
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/contact_information/new'
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      before do
        post \
          '/candidates/schools/11048/registrations/contact_information',
          params: contact_information_params
      end

      context 'invalid' do
        let :contact_information_params do
          {
            candidates_registrations_contact_information: {
              email: 'test@test.com'
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received :save
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'valid' do
        let :contact_information_params do
          {
            candidates_registrations_contact_information: \
              contact_information.attributes
          }
        end

        it 'updates the session with the new details' do
          expect(registration_session).to have_received(:save).with \
            contact_information
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/subject_preference/new'
        end
      end
    end
  end

  context 'with existing contact information in session' do
    let :existing_contact_information do
      contact_information
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/contact_information/edit'
      end

      it 'populates the form with the values from the session' do
        expect(assigns(:contact_information)).to eq existing_contact_information
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      before do
        patch \
          '/candidates/schools/11048/registrations/contact_information',
          params: contact_information_params
      end

      context 'invalid' do
        let :contact_information_params do
          {
            candidates_registrations_contact_information: {
              email: ''
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received :save
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :updated_contact_information do
          FactoryBot.build :contact_information, email: 'new-email@test.com'
        end

        let :contact_information_params do
          {
            candidates_registrations_contact_information: \
              updated_contact_information.attributes
          }
        end

        it 'updates the session' do
          expect(registration_session).to have_received(:save).with \
            updated_contact_information
        end

        it 'redirects to application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
