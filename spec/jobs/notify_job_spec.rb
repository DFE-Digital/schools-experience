require 'rails_helper'

shared_examples "notify_job" do
  include ActiveJob::TestHelper
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

  let :job do
    described_class.new \
      to: recipient,
      template_id: template_id,
      personalisation_json: personalisation.to_json
  end

  around { |example| perform_enqueued_jobs { example.run } }

  before do
    stub_const 'NotifyJob::API_KEY', api_key

    allow(NotifyService.instance).to receive(:notification_class) { notify_class }
    allow(described_class.queue_adapter).to receive :enqueue_at
    allow(Sentry).to receive :capture_exception

    allow(ActiveJob::Base.logger).to receive :info do |&block|
      personalisation.each_value { |v| expect(block.call).not_to include v }
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
          expect(Sentry).to have_received(:capture_exception).exactly(4).times
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
      let(:notify_class) { double Class, new: stub_client }
      let(:executions) { 1 }

      it 'sends the email' do
        expect(stub_client).to have_received(notify_method).with notify_method_params
      end
    end
  end
end

describe Notify::BaseNotifyJob, type: :job do
  context "#perform" do
    it "should fail with NotImplementedError'" do
      expect { subject.perform }.to raise_error(NotImplementedError, 'You must implement the perform method')
    end
  end
end

describe Notify::NotifyByEmailJob, type: :job do
  let(:recipient) { 'test@example.com' }
  let(:stub_client) { double Notifications::Client, send_email: true }
  let(:notify_method) { :send_email }
  let(:notify_method_params) do
    {
      template_id: template_id,
      email_address: recipient,
      personalisation: personalisation
    }
  end

  it_behaves_like "notify_job"
end

describe Notify::NotifyBySmsJob, type: :job do
  let(:recipient) { "07777777777" }
  let(:stub_client) { double Notifications::Client, send_sms: true }
  let(:notify_method) { :send_sms }
  let(:notify_method_params) do
    {
      template_id: template_id,
      phone_number: recipient,
      personalisation: personalisation
    }
  end

  it_behaves_like "notify_job"
end
