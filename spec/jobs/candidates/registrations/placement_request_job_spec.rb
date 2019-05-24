require 'rails_helper'

describe Candidates::Registrations::PlacementRequestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let :uuid do
    'some-uuid'
  end

  let :analytics_tracking_uuid do
    'some-analytics-uuid'
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
      context 'with only a uuid' do
        before do
          described_class.perform_later uuid
        end

        it 'calls PlacementRequestAction with a uuid' do
          expect(Candidates::Registrations::PlacementRequestAction).to \
            have_received(:new).with(uuid, nil)

          expect(placement_request_action).to have_received(:perform!)
        end
      end

      context 'with a uuid and an analytics_tracking_uuid' do
        before do
          described_class.perform_later uuid, analytics_tracking_uuid
        end

        it 'calls PlacementRequestAction with a uuid and a analytics_tracking_uuid' do
          expect(Candidates::Registrations::PlacementRequestAction).to \
            have_received(:new).with(uuid, analytics_tracking_uuid)

          expect(placement_request_action).to have_received :perform!
        end
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
        let :number_of_executions do
          2
        end

        let :a_decent_amount_longer do
          10.minutes.from_now.to_i
        end

        before do
          allow_any_instance_of(described_class).to receive(:executions) do
            number_of_executions
          end

          allow(placement_request_action).to receive :perform! do
            raise Notify::RetryableError
          end

          allow(described_class.queue_adapter).to receive :enqueue_at

          freeze_time # so we can easily compare a decent_amount_longer from now

          described_class.perform_later uuid
        end

        it 'reenqueues the job' do
          expect(described_class.queue_adapter).to \
            have_received(:enqueue_at).with \
              an_instance_of(described_class), a_decent_amount_longer
        end
      end
    end
  end
end
