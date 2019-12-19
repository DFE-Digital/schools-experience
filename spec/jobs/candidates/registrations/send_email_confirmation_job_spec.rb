require 'rails_helper'

describe Candidates::Registrations::SendEmailConfirmationJob, type: :job do
  include ActiveJob::TestHelper
  include_context 'Stubbed candidates school'

  let(:registration_session) { FactoryBot.build :registration_session }
  let(:uuid) { registration_session.uuid }
  let(:host) { 'www.example.com' }
  let(:template_id) { NotifyEmail::CandidateMagicLink.template_id }

  before do
    allow(SecureRandom).to receive(:urlsafe_base64) { uuid }
    allow(NotifyService.instance).to receive :send_email
    Candidates::Registrations::RegistrationStore.instance.store! \
      registration_session
  end

  after do
    # Clean up redis
    Candidates::Registrations::RegistrationStore.instance.delete! uuid
  end

  context '#perform' do
    before do
      perform_enqueued_jobs do
        described_class.perform_later uuid, host
      end
    end

    it 'delivers the email' do
      expect(NotifyService.instance).to have_received(:send_email).with \
        template_id: template_id,
        email_address: registration_session.email,
        personalisation: {
          school_name: registration_session.school_name,
          confirmation_link: 'https://www.example.com/candidates/confirm/some-uuid'
        }
    end
  end
end
