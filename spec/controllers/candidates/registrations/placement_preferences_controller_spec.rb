require 'rails_helper'

describe Candidates::Registrations::PlacementPreferencesController, type: :request do
  let! :tomorrow do
    Date.tomorrow
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
        expect(session['registration']['candidates_registrations_placement_preference']).to eq(
          "date_start" => tomorrow,
          "date_end" => (tomorrow + 3.days),
          "objectives" => 'Become a teacher',
          "access_needs" => false,
          "access_needs_details" => nil
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/account_check/new'
      end
    end
  end
end
