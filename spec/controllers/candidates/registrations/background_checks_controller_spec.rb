require 'rails_helper'

describe Candidates::Registrations::BackgroundChecksController, type: :request do
  context '#new' do
    before do
      get '/candidates/registrations/background_check/new'
    end

    it 'renders the new form' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidates/registrations/background_check/',
        params: background_check_params
    end

    context 'invalid' do
      let :background_check_params do
        {
          candidates_registrations_background_check: { has_dbs_check: nil }
        }
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :background_check_params do
        {
          candidates_registrations_background_check: { has_dbs_check: true }
        }
      end

      it 'stores the dbs check in the session' do
        expect(session[:registration][:background_check]).to eq \
          'has_dbs_check' => true
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/registrations/placement_request'
      end
    end
  end
end
