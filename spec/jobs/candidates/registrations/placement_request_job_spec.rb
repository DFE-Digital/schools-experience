require 'rails_helper'

describe Candidates::Registrations::PlacementRequestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let :uuid do
    'some-uuid'
  end

  let :placement_request_action do
    double Candidates::Registrations::PlacementRequestAction, perform!: true
  end

  before do
    ActiveJob::Base.queue_adapter = :inline
    allow(Candidates::Registrations::PlacementRequestAction).to \
      receive(:new) { placement_request_action }
  end

  context '#perform' do
    context 'no errors' do
      before do
        described_class.perform_later uuid
      end

      it 'calls PlacementRequestAction with the correct arguments' do
        expect(Candidates::Registrations::PlacementRequestAction).to \
          have_received(:new).with(uuid)

        expect(placement_request_action).to have_received :perform!
      end
    end

    context 'with errors' do
      context 'non retryable' do
        let :application_job_retry_limit do
          3
        end

        let :expected_error do
          double StandardError
        end

        before do
          allow(placement_request_action).to receive :perform! do
            raise 'Oh no!'
          end

          allow_any_instance_of(described_class).to receive :executions do
            application_job_retry_limit
          end
        end

        it 'lets the error propogate' do
          expect { described_class.perform_later uuid }.to raise_error \
            RuntimeError, 'Oh no!'
        end
      end

      context 'retryable error' do
        let :exponentially_longer do
          3.seconds.from_now.to_f
        end

        before do
          allow(placement_request_action).to receive :perform! do
            raise Notify::RetryableError
          end

          allow(described_class.queue_adapter).to receive :enqueue_at

          freeze_time # so we can easily compare 3.seconds.from_now

          described_class.perform_later uuid
        end

        it 'reenqueues the job' do
          expect(described_class.queue_adapter).to \
            have_received(:enqueue_at).with \
              an_instance_of(described_class), exponentially_longer
        end
      end
    end
  end
end
