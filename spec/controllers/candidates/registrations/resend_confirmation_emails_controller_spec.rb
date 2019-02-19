require 'rails_helper'

describe Candidates::Registrations::ResendConfirmationEmailsController, type: :request do
  include_context 'Stubbed candidates school'

  let! :registration_session do
    FactoryBot.build :registration_session
  end

  let! :uuid do
    Candidates::Registrations::RegistrationStore.instance.store! \
      registration_session
  end

  before do
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive :perform_later
  end

  context '#create' do
    context 'registration not found' do
      before do
        post \
          candidates_school_registrations_resend_confirmation_email_path \
            registration_session.school,
            uuid: '12345'
      end

      it 'shows the user the session expired page' do
        expect(response).to render_template :session_expired
      end
    end

    context 'registration found' do
      before do
        post \
          candidates_school_registrations_resend_confirmation_email_path \
            registration_session.school,
            email: registration_session.email,
            school_name: registration_session.school.name,
            uuid: uuid
      end

      it 'resends the confirmation email' do
        expect(Candidates::Registrations::SendEmailConfirmationJob).to \
          have_received(:perform_later).with uuid
      end

      it 'redirects to confirmation email show' do
        expect(response).to redirect_to \
          candidates_school_registrations_confirmation_email_path(
            registration_session.school,
            email: registration_session.email,
            school_name: registration_session.school.name,
            uuid: uuid
        )
      end
    end
  end
end
