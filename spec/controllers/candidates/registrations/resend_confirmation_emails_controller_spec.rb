require 'rails_helper'

describe Candidates::Registrations::ResendConfirmationEmailsController, type: :request do
  include_context 'Stubbed candidates school'

  let! :registration_session do
    FactoryBot.build :registration_session
  end

  before do
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive :perform_later

    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
  end

  context '#create' do
    context 'session not pending email confirmation' do
      before do
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
end
