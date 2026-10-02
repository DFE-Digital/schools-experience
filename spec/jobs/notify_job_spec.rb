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
              an_instance_of(described_class), be_within(3.seconds).of(retry_in)
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

shared_examples "notify recipient restriction handling" do
  include ActiveJob::TestHelper

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

  # The exact messages GOV.UK Notify returns for a team-only/trial-mode key.
  let(:team_only_message) { "Cannot send to this recipient using a team-only API key." }
  let(:trial_mode_message) do
    "Cannot send to this recipient when service is in trial mode " \
      "– see https://www.notifications.service.gov.uk/trial-mode"
  end
  let(:other_bad_request_message) { "template_id is not a valid UUID" }

  # Builds a Notify client that raises a 400 BadRequestError carrying the given
  # message, for both email and sms sends.
  def erroring_client(message)
    Class.new do
      define_method(:initialize) { |_api_key = nil| }
      define_method(:send_email) do |*_args|
        raise Notifications::Client::BadRequestError,
          OpenStruct.new(body: message, code: 400)
      end
      define_method(:send_sms) do |*_args|
        raise Notifications::Client::BadRequestError,
          OpenStruct.new(body: message, code: 400)
      end
    end
  end

  around { |example| perform_enqueued_jobs { example.run } }

  before do
    allow(NotifyService.instance).to receive(:notification_class) { notify_class }
    allow(described_class.queue_adapter).to receive :enqueue_at
    allow(Sentry).to receive :capture_exception
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(rails_env))
  end

  context 'outside production' do
    let(:rails_env) { 'staging' }

    context 'team-only API key error' do
      let(:notify_class) { erroring_client(team_only_message) }

      it 'does not raise' do
        expect { job.perform_now }.not_to raise_error
      end

      it 'does not retry the job' do
        job.perform_now
        expect(described_class.queue_adapter).not_to have_received(:enqueue_at)
      end

      it 'does not alert monitoring' do
        job.perform_now
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context 'trial mode error' do
      let(:notify_class) { erroring_client(trial_mode_message) }

      it 'swallows the error without retrying or alerting' do
        expect { job.perform_now }.not_to raise_error
        expect(described_class.queue_adapter).not_to have_received(:enqueue_at)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context 'any other bad request error' do
      let(:notify_class) { erroring_client(other_bad_request_message) }

      it 'lets the error propagate to be retried' do
        job.perform_now
        expect(described_class.queue_adapter).to have_received(:enqueue_at)
      end
    end
  end

  context 'in production' do
    let(:rails_env) { 'production' }

    context 'team-only API key error' do
      let(:notify_class) { erroring_client(team_only_message) }

      it 'lets the error propagate to be retried' do
        job.perform_now
        expect(described_class.queue_adapter).to have_received(:enqueue_at)
      end
    end

    context 'trial mode error' do
      let(:notify_class) { erroring_client(trial_mode_message) }

      it 'lets the error propagate to be retried' do
        job.perform_now
        expect(described_class.queue_adapter).to have_received(:enqueue_at)
      end
    end
  end
end

describe Notify::BaseJob, type: :job do
  context "#perform" do
    it "should fail with NotImplementedError'" do
      expect { subject.perform }.to raise_error(NotImplementedError, 'You must implement the perform method')
    end
  end
end

describe Notify::EmailJob, type: :job do
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
  it_behaves_like "notify recipient restriction handling"
end

describe Notify::SmsJob, type: :job do
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
  it_behaves_like "notify recipient restriction handling"
end
