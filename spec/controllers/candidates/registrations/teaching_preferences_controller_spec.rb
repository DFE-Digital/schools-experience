require 'rails_helper'

describe Candidates::Registrations::TeachingPreferencesController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  let :registration_session do
    FactoryBot.build :registration_session, with: %i[
      personal_information
      contact_information
      education
    ]
  end

  context '#new' do
    context 'without existing teaching_preference in the session' do
      before do
        get '/candidates/schools/11048/registrations/teaching_preference/new'
      end

      it 'assigns the model with empty attributes' do
        expect(assigns(:teaching_preference).attributes).to eq \
          Candidates::Registrations::TeachingPreference.new.attributes
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'with existing teaching_preference in the session' do
      let :teaching_preference do
        FactoryBot.build :teaching_preference
      end

      before do
        registration_session.save teaching_preference
      end

      before do
        get '/candidates/schools/11048/registrations/teaching_preference/new'
      end

      it 'assigns the model with the existing attributes' do
        expect(assigns(:teaching_preference).attributes).to eq \
          teaching_preference.attributes
      end

      it "sets the model's school" do
        expect(assigns(:teaching_preference).school).to eq school
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end
  end

  context '#create' do
    let :teaching_preference_params do
      {
        candidates_registrations_teaching_preference: \
          teaching_preference.attributes
      }
    end

    before do
      post '/candidates/schools/11048/registrations/teaching_preference',
        params: teaching_preference_params
    end

    context 'invalid' do
      let :teaching_preference do
        Candidates::Registrations::TeachingPreference.new
      end

      it "doesn't modify the session" do
        expect { registration_session.teaching_preference }.to raise_error \
          Candidates::Registrations::RegistrationSession::StepNotFound
      end

      it 'rerenders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :teaching_preference do
        FactoryBot.build :teaching_preference
      end

      it 'stores the teaching preference in the session' do
        expect(registration_session.teaching_preference).to \
          eq_model teaching_preference
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/11048/registrations/placement_preference/new'
      end
    end
  end

  context '#edit' do
    let :exisitng_teaching_preference do
      FactoryBot.build :teaching_preference
    end

    before do
      registration_session.save exisitng_teaching_preference
    end

    before do
      get '/candidates/schools/11048/registrations/teaching_preference/edit'
    end

    it 'assigns the model with existing attributes' do
      expect(assigns(:teaching_preference).attributes).to eq \
        exisitng_teaching_preference.attributes
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    let :exisitng_teaching_preference do
      FactoryBot.build :teaching_preference
    end

    before do
      registration_session.save exisitng_teaching_preference
    end

    let :teaching_preference_params do
      {
        candidates_registrations_teaching_preference: \
          teaching_preference.attributes
      }
    end

    before do
      patch '/candidates/schools/11048/registrations/teaching_preference',
        params: teaching_preference_params
    end

    context 'invalid' do
      let :teaching_preference do
        Candidates::Registrations::TeachingPreference.new
      end

      it 'rerenders the edit form' do
        expect(response).to render_template :edit
      end

      it "doesn't update the session" do
        expect(registration_session.teaching_preference).to \
          eq_model exisitng_teaching_preference
      end
    end

    context 'valid' do
      let :teaching_preference do
        FactoryBot.build :teaching_preference,
          teaching_stage: 'I’m not sure and finding out more'
      end

      it 'updates the the session' do
        expect(registration_session.teaching_preference).to \
          eq_model teaching_preference
      end

      it 'redirects to the application preview' do
        expect(response).to redirect_to \
          candidates_school_registrations_application_preview_path
      end
    end
  end
end
