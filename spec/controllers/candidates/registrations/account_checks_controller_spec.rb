require 'rails_helper'

describe Candidates::Registrations::AccountChecksController, type: :request do
  context '#new' do
    before do
      get '/candidates/schools/URN/registrations/account_check/new'
    end

    it 'renders the new template' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidates/schools/URN/registrations/account_check',
        params: account_check_params
    end

    context 'invalid' do
      let :account_check_params do
        {
          candidates_registrations_account_check: {
            full_name: 'test name'
          }
        }
      end

      it 'renders the new template' do
        expect(response).to render_template :new
      end
    end

    context 'valid' do
      let :account_check_params do
        {
          candidates_registrations_account_check: {
            full_name: 'test name',
            email: 'test@example.com'
          }
        }
      end

      it 'stores the account_check details in the session' do
        expect(session['registration']['candidates_registrations_account_check']).to eq(
          'full_name' => 'test name',
          'email' => 'test@example.com',
          'created_at' => nil,
          'updated_at' => nil
        )
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/address/new'
      end
    end
  end
end
