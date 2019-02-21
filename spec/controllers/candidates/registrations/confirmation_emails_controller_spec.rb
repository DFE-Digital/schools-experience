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
    double Candidates::Registrations::RegistrationStore, store!: uuid
  end

  before do
    allow(Candidates::Registrations::RegistrationStore).to \
      receive(:instance) { registration_store }
    allow(Candidates::Registrations::RegistrationSession).to \
      receive(:new) { registration_session }
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive(:perform_later)
  end

  context '#create' do
    context 'success' do
      before do
        post candidates_school_registrations_confirmation_email_path(school)
      end

      it 'stores the session' do
        expect(registration_store).to have_received(:store!).with \
          registration_session
      end

      it 'enqueues the confirmation email job' do
        expect(Candidates::Registrations::SendEmailConfirmationJob).to \
          have_received(:perform_later).with uuid
      end

      it 'redirects to the check your email page' do
        expect(response).to redirect_to \
          candidates_school_registrations_confirmation_email_path \
            school,
            email: registration_session.email,
            school_name: registration_session.school.name,
            uuid: uuid
      end
    end
  end

  context '#show' do
    before do
      get candidates_school_registrations_confirmation_email_path \
        school,
        email: 'test@test.com',
        school_name: 'test school',
        uuid: uuid
    end

    it 'assigns email for the view' do
      expect(assigns(:email)).to eq 'test@test.com'
    end

    it 'assigns school name for the view' do
      expect(assigns(:school_name)).to eq 'test school'
    end

    it 'assigns retry path for the view' do
      expect(assigns(:resend_path)).to eq \
        '/candidates/schools/11048/registrations/resend_confirmation_email?email=test%40test.com&school_name=test+school&uuid=some-uuid'
    end
  end
end
