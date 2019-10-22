require 'rails_helper'

describe Candidates::Registrations::ResendConfirmationEmailsController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  let :registration_session do
    build :flattened_registration_session
  end

  before do
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive :perform_later
  end

  context '#create' do
    context 'session found' do
      context 'session not pending email confirmation' do
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

      context 'session pending email confirmation' do
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

    context 'session not found' do
      before do
        allow(ExceptionNotifier).to receive :notify_exception

        Candidates::Registrations::RegistrationStore.instance.store! \
          registration_session

        Candidates::Registrations::RegistrationStore.instance.delete! \
          registration_session.uuid

        post candidates_school_registrations_resend_confirmation_email_path \
          registration_session.school
      end

      it 'notifys exception monitoring' do
        expect(ExceptionNotifier).to have_received(:notify_exception).with(
          Candidates::Registrations::RegistrationStore::SessionNotFound,
          data: {
            action: 'ResendConfirmationEmailsController#create',
            uuid: registration_session.uuid
          }
        )
      end

      it 'renders the shared/session_expired?' do
        expect(response).to render_template 'shared/session_expired'
      end
    end
  end
end
