require 'rails_helper'

describe Candidates::Registrations::SubjectPreferencesController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  let :registration_session do
    Candidates::Registrations::RegistrationSession.new({})
  end

  context 'without existing subject_preference in session' do
    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/subject_preference/new'
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      let :subject_preference_params do
        {
          candidates_registrations_subject_preference: \
            subject_preference.attributes
        }
      end

      before do
        post '/candidates/schools/11048/registrations/subject_preference',
          params: subject_preference_params
      end

      context 'invalid' do
        let :subject_preference do
          Candidates::Registrations::SubjectPreference.new
        end

        it 'doesnt modify the session' do
          expect { registration_session.subject_preference }.to raise_error \
            Candidates::Registrations::RegistrationSession::StepNotFound
        end

        it 'rerenders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'valid' do
        let :subject_preference do
          FactoryBot.build :subject_preference, urn: school.urn
        end

        it 'stores the subject_preference in the session' do
          expect(registration_session.subject_preference).to \
            eq_model subject_preference
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/placement_preference/new'
        end
      end
    end
  end

  context 'with existing subject_preference in session' do
    let :existing_subject_preference do
      FactoryBot.build :subject_preference, urn: school.urn
    end

    before do
      registration_session.save existing_subject_preference
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/subject_preference/new'
      end

      it 'populates the new form with values from the session' do
        expect(assigns(:subject_preference)).to \
          eq_model existing_subject_preference
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/subject_preference/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:subject_preference)).to \
          eq_model existing_subject_preference
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      let :subject_preference_params do
        {
          candidates_registrations_subject_preference: \
            subject_preference.attributes
        }
      end

      before do
        patch '/candidates/schools/11048/registrations/subject_preference',
          params: subject_preference_params
      end

      context 'invalid' do
        let :subject_preference do
          Candidates::Registrations::SubjectPreference.new
        end

        it 'doesnt modify the session' do
          expect(registration_session.subject_preference).to \
            eq_model existing_subject_preference
        end

        it 'rerenders the edit template' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :subject_preference do
          FactoryBot.build \
            :subject_preference, :with_degree_stage_other, urn: school.urn
        end

        it 'updates the session with the new details' do
          expect(registration_session.subject_preference).to \
            eq_model subject_preference
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
