require 'rails_helper'

describe Candidates::Registrations::BackgroundChecksController, type: :request do
  let! :date do
    DateTime.now
  end

  let :registration_session do
    double Candidates::Registrations::RegistrationSession,
      save: true,
      background_check: existing_background_check
  end

  before do
    allow(DateTime).to receive(:now) { date }

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context 'without existing background_check in session' do
    let :existing_background_check do
      nil
    end

    context '#new' do
      before do
        get '/candidates/schools/11048/registrations/background_check/new'
      end

      it 'renders the new form' do
        expect(response).to render_template :new
      end
    end

    context '#create' do
      before do
        post '/candidates/schools/11048/registrations/background_check/',
          params: background_check_params
      end

      context 'invalid' do
        let :background_check_params do
          {
            candidates_registrations_background_check: { has_dbs_check: nil }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
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
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::BackgroundCheck.new \
              has_dbs_check: true
        end

        it 'redirects to the next step' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end

  context 'with existing background check in session' do
    let :existing_background_check do
      Candidates::Registrations::BackgroundCheck.new \
        has_dbs_check: true
    end

    context '#edit' do
      before do
        get '/candidates/schools/11048/registrations/background_check/edit'
      end

      it 'populates the edit form with values from the session' do
        expect(assigns(:background_check)).to eq existing_background_check
      end

      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
    end

    context '#update' do
      before do
        patch '/candidates/schools/11048/registrations/background_check',
          params: background_check_params
      end

      context 'invalid' do
        let :background_check_params do
          {
            candidates_registrations_background_check: { has_dbs_check: nil }
          }
        end

        it 'doesnt modify the session' do
          expect(registration_session).not_to have_received(:save)
        end

        it 'rerenders the edit form' do
          expect(response).to render_template :edit
        end
      end

      context 'valid' do
        let :background_check_params do
          {
            candidates_registrations_background_check: { has_dbs_check: false }
          }
        end

        it 'updates the session with the new details' do
          expect(registration_session).to have_received(:save).with \
            Candidates::Registrations::BackgroundCheck.new \
              has_dbs_check: false
        end

        it 'redirects to the application preview' do
          expect(response).to redirect_to \
            '/candidates/schools/11048/registrations/application_preview'
        end
      end
    end
  end
end
