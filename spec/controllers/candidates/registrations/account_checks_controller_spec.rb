require 'rails_helper'

describe Candidates::Registrations::AccountChecksController, type: :request do
  let :account_check do
    Candidates::Registrations::AccountCheck.new \
      full_name: 'test name',
      email: 'test@example.com'
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      account_check: account_check,
      save: false
  end

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

      it 'doesnt modify the session' do
        expect(session).not_to be_loaded
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
        expect(
          session['registration']['candidates_registrations_account_check']
        ).to eq \
          'full_name' => 'test name',
          'email' => 'test@example.com',
          'created_at' => nil,
          'updated_at' => nil
      end

      it 'redirects to the next step' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/address/new'
      end
    end
  end

  context '#edit' do
    before do
      allow(Candidates::Registrations::RegistrationSession).to \
        receive(:new) { registration_session }
    end

    before do
      get '/candidates/schools/URN/registrations/account_check/edit'
    end

    it 'populates the edit form with values from the session' do
      expect(assigns(:account_check).full_name).to eq account_check.full_name
      expect(assigns(:account_check).email).to eq account_check.email
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end
  end

  context '#update' do
    before do
      patch '/candidates/schools/URN/registrations/account_check',
        params: account_check_params
    end

    context 'invalid' do
      let :account_check_params do
        {
          candidates_registrations_account_check: {
            full_name: 'new name'
          }
        }
      end

      it 'doesnt modify the session' do
        expect(session).not_to be_loaded
      end

      it 'rerenders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'valid' do
      let :account_check_params do
        {
          candidates_registrations_account_check: {
            full_name: 'new name',
            email: 'new-email@example.com'
          }
        }
      end

      it 'updates the session with the new details' do
          expect(
            session['registration']['candidates_registrations_account_check']
          ).to eq \
            'full_name' => 'new name',
            'email' => 'new-email@example.com'
      end

      it 'redirects to the application preview' do
        expect(response).to redirect_to \
          '/candidates/schools/URN/registrations/application_preview'
      end
    end
  end
end
