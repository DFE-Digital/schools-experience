require 'rails_helper'

describe Candidates::Registrations::ConfirmationEmailsController, type: :request do
  include_context 'Stubbed candidates school'

  let! :registration_session do
    FactoryBot.build :registration_session
  end

  let! :uuid do
    'some-uuid'
  end

  let! :registration_store do
    double Candidates::Registrations::RegistrationStore, store!: 1
  end

  before do
    allow(SecureRandom).to receive(:urlsafe_base64) { uuid }
    allow(Candidates::Registrations::RegistrationStore).to \
      receive(:instance) { registration_store }
    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive(:perform_later)
  end

  context '#create' do
    context 'privacy policy not accepted' do
      let :privacy_policy_params do
        { candidates_registrations_privacy_policy: { acceptance: '0' } }
      end

      before do
        post candidates_school_registrations_confirmation_email_path(school),
          params: privacy_policy_params
      end

      it 'renders the application_preview show template' do
        expect(response).to render_template \
          'candidates/registrations/application_previews/show'
      end

      it "doesn't enqueues the confirmation email job" do
        expect(Candidates::Registrations::SendEmailConfirmationJob).not_to \
          have_received :perform_later
      end
    end

    context 'privacy policy accepted' do
      let :privacy_policy_params do
        { candidates_registrations_privacy_policy: { acceptance: '1' } }
      end

      context 'skipped step' do
        before do
          allow(registration_session).to receive(:flag_as_pending_email_confirmation!) {
            raise Candidates::Registrations::RegistrationSession::NotCompletedError
          }

          post candidates_school_registrations_confirmation_email_path(school),
            params: privacy_policy_params
        end

        it "doesn't store the session" do
          expect(registration_store).not_to have_received(:store!).with \
            registration_session
        end

        it "doesn't enqueues the confirmation email job" do
          expect(Candidates::Registrations::SendEmailConfirmationJob).not_to \
            have_received(:perform_later).with uuid, 'www.example.com'
        end

        it "redirects to the application preview path" do
          expect(response).to redirect_to \
            candidates_school_registrations_application_preview_path school
        end
      end

      context 'no skipped steps' do
        before do
          post candidates_school_registrations_confirmation_email_path(school),
            params: privacy_policy_params
        end

        it 'marks the session as pending' do
          expect(registration_session).to be_pending_email_confirmation
        end

        it 'stores the session' do
          expect(registration_store).to have_received(:store!).with \
            registration_session
        end

        it 'enqueues the confirmation email job' do
          expect(Candidates::Registrations::SendEmailConfirmationJob).to \
            have_received(:perform_later).with uuid, 'www.example.com'
        end

        it 'redirects to the check your email page' do
          expect(response).to redirect_to \
            candidates_school_registrations_confirmation_email_path school
        end
      end
    end
  end

  context '#show' do
    before do
      get candidates_school_registrations_confirmation_email_path school
    end

    it 'assigns email for the view' do
      expect(assigns(:email)).to eq 'test@example.com'
    end

    it 'assigns school name for the view' do
      expect(assigns(:school_name)).to eq 'Test School'
    end

    it 'assigns retry path for the view' do
      expect(assigns(:resend_path)).to eq \
        '/candidates/schools/11048/registrations/resend_confirmation_email'
    end
  end
end
