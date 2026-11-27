require 'rails_helper'

describe Candidates::Registrations::ResendConfirmationEmailsController, type: :request do
  include_context 'with a stubbed candidate school'
  include_context 'with a stubbed current registration'

  let :registration_session do
    FactoryBot.build :registration_session
  end

  before do
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive :perform_later
  end

  describe '#create' do
    context 'when session found' do
      context 'when session not pending email confirmation' do
        before do
          Candidates::Registrations::RegistrationStore.instance.store! \
            registration_session

          post candidates_school_registrations_resend_confirmation_email_path \
            registration_session.school
        end

        it "doesn't resend the confirmation email" do
          expect(Candidates::Registrations::SendEmailConfirmationJob).not_to \
            have_received(:perform_later).with \
              registration_session.uuid, 'www.example.com'
        end

        it 'renders the session expired template' do
          expect(response).to render_template :session_expired
        end
      end

      context 'when session pending email confirmation' do
        before do
          registration_session.flag_as_pending_email_confirmation!

          Candidates::Registrations::RegistrationStore.instance.store! \
            registration_session

          post candidates_school_registrations_resend_confirmation_email_path \
            registration_session.school
        end

        it 'resends the confirmation email' do
          expect(Candidates::Registrations::SendEmailConfirmationJob).to \
            have_received(:perform_later).with \
              registration_session.uuid, 'www.example.com'
        end

        it 'redirects to confirmation email show' do
          expect(response).to redirect_to \
            candidates_school_registrations_confirmation_email_path \
              registration_session.school
        end
      end
    end

    context 'when session not found' do
      before do
        allow(Sentry).to receive :capture_exception

        Candidates::Registrations::RegistrationStore.instance.store! \
          registration_session

        Candidates::Registrations::RegistrationStore.instance.delete! \
          registration_session.uuid

        post candidates_school_registrations_resend_confirmation_email_path \
          registration_session.school
      end

      it 'notifies exception monitoring' do
        expect(Sentry).to have_received(:capture_exception).with \
          kind_of(Candidates::Registrations::RegistrationStore::SessionNotFound)
      end

      it 'renders the shared/session_expired?' do
        expect(response).to render_template 'shared/session_expired'
      end
    end
  end
end
