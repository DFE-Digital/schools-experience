require 'rails_helper'

describe Candidates::Registrations::PlacementPreferencesController, type: :request do
  let! :date do
    DateTime.now
  end

  let! :tomorrow do
    date.tomorrow
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession, save: true
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context '#new' do
    before do
      get '/candidates/schools/URN/registrations/placement_preference/new'
    end

    it 'responds with 200' do
      expect(response.status).to eq 200
    end

    it 'renders the new form' do
      expect(response.body).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidates/schools/URN/registrations/placement_preference',
        params: placement_preference_params
    end

    context 'invalid' do
      let :placement_preference_params do
        {
          candidates_registrations_placement_preference: {
            date_start: tomorrow
          }
        }
      end

      it 'doesnt modify the session' do
        expect(registration_session).not_to have_received(:save)
      end

      it 'rerenders the new form' do
        expect(response.body).to render_template :new
      end
    end

    context 'valid' do
      let :placement_preference_params do
        {
          candidates_registrations_placement_preference: {
            date_start: tomorrow,
            date_end: (tomorrow + 3.days),
            objectives: 'Become a teacher',
            access_needs: false
          }
        }
      end

      it 'stores the placement_preference details in the session' do
        expect(registration_session).to have_received(:save).with \
          Candidates::Registrations::PlacementPreference.new \
            date_start: tomorrow,
            date_end: (tomorrow + 3.days),
            objectives: 'Become a teacher',
            access_needs: false
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/account_check/new'
      end
    end
  end
end
