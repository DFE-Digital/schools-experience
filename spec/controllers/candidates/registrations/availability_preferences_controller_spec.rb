require 'rails_helper'

describe Candidates::Registrations::AvailabilityPreferencesController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  let :registration_session do
    FactoryBot.build :registration_session, with: %i[
      subject_and_date_information
      personal_information
      contact_information
      education
      teaching_preference
      placement_preference
    ]
  end

  context 'without existing availability_preference in session' do
    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/availability_preference/new'
      end

      it 'responds with 200' do
        expect(response.status).to eq 200
      end

      it 'renders the new form' do
        expect(response.body).to render_template :new
      end
    end

    context '#create' do
      let :availability_preference_params do
        {
          candidates_registrations_availability_preference: \
            availability_preference.attributes
        }
      end

      before do
        post '/candidates/schools/11048/registrations/availability_preference',
          params: availability_preference_params
      end

      context 'invalid' do
        let :availability_preference do
          Candidates::Registrations::AvailabilityPreference.new
        end

        it 'doesnt modify the session' do
          expect { registration_session.availability_preference }.to raise_error \
            Candidates::Registrations::RegistrationSession::StepNotFound
        end

        it 'rerenders the new form' do
          expect(response.body).to render_template :new
        end
      end

      context 'valid' do
        let :availability_preference do
          FactoryBot.build :availability_preference, urn: school.urn
        end

        it 'stores the availability_preference details in the session' do
          expect(registration_session.availability_preference).to \
            eq_model availability_preference
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/background_check/new'
        end
      end
    end
  end

  context 'with existing availability_preference in session' do
    let :existing_availability_preference do
      FactoryBot.build :availability_preference, urn: school.urn
    end

    before do
      registration_session.save existing_availability_preference
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/availability_preference/new'
      end

      it 'populates the new form with values from the session' do
        expect(assigns(:availability_preference)).to eq_model \
          existing_availability_preference
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/availability_preference/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:availability_preference)).to eq_model \
          existing_availability_preference
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      let :availability_preference_params do
        {
          candidates_registrations_availability_preference: \
            availability_preference.attributes
        }
      end

      before do
        patch '/candidates/schools/11048/registrations/availability_preference',
          params: availability_preference_params
      end

      context 'invalid' do
        let :availability_preference do
          Candidates::Registrations::AvailabilityPreference.new
        end

        it 'doesnt modify the session' do
          expect(registration_session.availability_preference).to \
            eq existing_availability_preference
        end

        it 'rerenders the edit template' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :availability_preference do
          FactoryBot.build :availability_preference,
            urn: school.urn,
            availability: 'Every second Friday'
        end

        it 'updates the session with the new details' do
          expect(registration_session.availability_preference).to eq_model \
            availability_preference
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
