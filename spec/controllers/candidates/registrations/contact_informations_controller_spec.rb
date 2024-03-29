require 'rails_helper'

describe Candidates::Registrations::ContactInformationsController, type: :request do
  include_context 'Stubbed current_registration'
  let!(:school) { create(:bookings_school, urn: 11_048) }

  let(:gitis_contact) { build(:api_schools_experience_sign_up_with_name) }

  context 'without existing contact information in the session' do
    let :registration_session do
      FactoryBot.build :registration_session, with: %i[personal_information]
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
      let :contact_information_params do
        {
          candidates_registrations_contact_information: \
            contact_information.attributes
        }
      end

      before do
        post \
          '/candidates/schools/11048/registrations/contact_information',
          params: contact_information_params
      end

      context 'invalid' do
        let :contact_information do
          Candidates::Registrations::ContactInformation.new
        end

        it 'doesnt modify the session' do
          expect { registration_session.contact_information }.to raise_error \
            Candidates::Registrations::RegistrationSession::StepNotFound
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'valid' do
        let :contact_information do
          FactoryBot.build :contact_information
        end

        it 'updates the session with the new details' do
          expect(registration_session.contact_information).to \
            eq_model contact_information
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/education/new'
        end
      end
    end
  end

  context 'with existing contact information in gitis' do
    let :registration_session do
      FactoryBot.build :gitis_registration_session,
        gitis_contact: gitis_contact,
        with: %i[personal_information]
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/contact_information/new'
      end

      it 'populates the form with the values from gitis' do
        expect(assigns(:contact_information)).to have_attributes \
          phone: gitis_contact.telephone,
          postcode: gitis_contact.address_postcode
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context 'with existing contact information in session' do
    let :registration_session do
      FactoryBot.build :gitis_registration_session,
        gitis_contact: gitis_contact,
        with: %i[personal_information]
    end

    let :existing_contact_information do
      FactoryBot.build :contact_information
    end

    before do
      registration_session.save existing_contact_information
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/contact_information/new'
      end

      it 'populates the form with the values from the session' do
        expect(assigns(:contact_information)).to \
          eq_model existing_contact_information
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
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
      let :contact_information_params do
        {
          candidates_registrations_contact_information: \
            contact_information.attributes
        }
      end

      before do
        patch \
          '/candidates/schools/11048/registrations/contact_information',
          params: contact_information_params
      end

      context 'invalid' do
        let :contact_information do
          Candidates::Registrations::ContactInformation.new
        end

        it 'doesnt modify the session' do
          expect(registration_session.contact_information).not_to \
            eq_model contact_information
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :contact_information do
          FactoryBot.build :contact_information, town_or_city: 'Manchester'
        end

        it 'updates the session' do
          expect(registration_session.contact_information).to \
            eq_model contact_information
        end

        it 'redirects to application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
