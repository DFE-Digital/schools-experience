require 'rails_helper'

describe NotifyJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let :api_key do
    ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
  end

  let :personalisation do
    { school_name: "A School", confirmation_link: "ABC123" }
  end

  let :template_id do
    '11111111-aaaa-1111-aaaa-111111111111'
  end

  let :email_address do
    'test@example.com'
  end

  let :job do
    described_class.new \
      to: email_address,
      template_id: template_id,
      personalisation_json: personalisation.to_json
  end

  before do
    stub_const 'NotifyJob::API_KEY', api_key

    ActiveJob::Base.queue_adapter = :inline

    allow(NotifyService.instance).to receive(:notification_class) { notify_class }
    allow(described_class.queue_adapter).to receive :enqueue_at
    allow(ExceptionNotifier).to receive :notify_exception
    allow(Raven).to receive :capture_exception

    allow(ActiveJob::Base.logger).to receive :info do |&block|
      personalisation.values.each { |v| expect(block.call).not_to include v }
      expect(block.call).not_to include email_address
    end

    freeze_time

    executions.times { job.perform_now }
  end

  context '#perform' do
    context 'on error' do
      context 'retryable error' do
        let(:notify_class) { NotifyRetryableErroringClient }
        let(:executions) { 4 }
        let(:retry_in) { 2.hours.from_now.to_i }

        # https://docs.notifications.service.gov.uk/ruby.html#error-codes
        it 'retrys the job' do
          expect(described_class.queue_adapter).to \
            have_received(:enqueue_at).with \
              an_instance_of(described_class), retry_in
        end

        it 'alerts monitoring' do
          expect(Raven).to have_received(:capture_exception).exactly(4).times
          expect(ExceptionNotifier).to \
            have_received(:notify_exception).exactly(4).times
        end
      end

      context 'non retryable error' do
        let(:notify_class) { NotifyNonRetryableErroringClient }
        let(:executions) { 2 }
        let(:application_job_timeout) { (executions**4) + 2 }
        let(:retry_in) { application_job_timeout.seconds.from_now.to_i }

        it 'lets the error propogate to application job' do
          expect(described_class.queue_adapter).to \
            have_received(:enqueue_at).with \
              an_instance_of(described_class), retry_in
        end
      end
    end

    context 'on success' do
      let(:stub_client) { double Notifications::Client, send_email: true }
      let(:notify_class) { double Class, new: stub_client }
      let(:executions) { 1 }

      it 'sends the email' do
        expect(stub_client).to have_received(:send_email).with \
          template_id: template_id,
          email_address: email_address,
          personalisation: personalisation
      end
    end
  end
end
