require 'rails_helper'

describe Candidates::Registrations::BackgroundChecksController, type: :request do
  let! :date do
    DateTime.now
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
      get '/candidates/schools/URN/registrations/background_check/new'
    end

    it 'renders the new form' do
      expect(response).to render_template :new
    end
  end

  context '#create' do
    before do
      post '/candidates/schools/URN/registrations/background_check/',
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

      it 'doesnt modify the session' do
        expect(registration_session).not_to have_received(:save)
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
          '/candidates/schools/URN/registrations/application_preview'
      end
    end
  end
end
