require 'rails_helper'

describe Candidates::Registrations::AccountChecksController, type: :request do
  let! :date do
    DateTime.now
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      account_check: existing_account_check,
      save: true
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context 'without existing account_check in session' do
    let :existing_account_check do
      nil
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
          expect(registration_session).not_to have_received(:save)
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
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::AccountCheck.new(
              full_name: 'test name',
              email: 'test@example.com'
            )
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/URN/registrations/address/new'
        end
      end
    end
  end

  context 'with existing account_check in session' do
    let :existing_account_check do
      Candidates::Registrations::AccountCheck.new \
        full_name: 'test name',
        email: 'test@example.com'
    end

    context '#edit' do
      before do
        get '/candidates/schools/URN/registrations/account_check/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:account_check)).to eq existing_account_check
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
              full_name: 'new name',
              email: ''
            }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
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
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::AccountCheck.new(
              full_name: 'new name',
              email: 'new-email@example.com'
            )
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/URN/registrations/application_preview'
        end
      end
    end
  end
end
