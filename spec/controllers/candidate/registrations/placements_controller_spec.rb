require 'rails_helper'

describe Candidate::Registrations::PlacementsController, type: :request do
  let! :tomorrow do
    Date.tomorrow
  end

  context '#new' do
    before do
      get '/candidate/registrations/placements/new'
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
      post '/candidate/registrations/placements', params: placement_params
    end

    context 'invalid' do
      let :placement_params do
        { candidate_registrations_placement: { date_start: tomorrow } }
      end

      it 'rerenders the new form' do
        expect(response.body).to render_template :new
      end
    end

    context 'valid' do
      let :placement_params do
        {
          candidate_registrations_placement: {
            date_start: tomorrow,
            date_end: (tomorrow + 3.days),
            objectives: 'Become a teacher',
            access_needs: false
          }
        }
      end

      it 'stores the placement details in the session' do
        expect(session[:registration][:placement]).to eq(
          "date_start" => tomorrow,
          "date_end" => (tomorrow + 3.days),
          "objectives" => 'Become a teacher',
          "access_needs" => false,
          "access_needs_details" => nil
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidate/registrations/account_checks/new'
      end
    end
  end
end
