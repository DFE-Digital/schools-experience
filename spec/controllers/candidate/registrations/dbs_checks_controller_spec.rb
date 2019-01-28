require 'rails_helper'

describe Candidate::Registrations::DbsChecksController, type: :request do
  context '#new' do
    before do
      get '/candidate/registrations/dbs_checks/new'
    end

    it 'renders the new form' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidate/registrations/dbs_checks/', params: dbs_check_params
    end

    context 'invalid' do
      let :dbs_check_params do
        {
          candidate_registrations_dbs_check: { has_dbs_check: nil }
        }
      end

      it 'rerenders the new form' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :dbs_check_params do
        {
          candidate_registrations_dbs_check: { has_dbs_check: true }
        }
      end

      it 'stores the dbs check in the session' do
        expect(session[:registration][:dbs_check]).to eq 'has_dbs_check' => true
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidate/registrations/placement_request'
      end
    end
  end
end
