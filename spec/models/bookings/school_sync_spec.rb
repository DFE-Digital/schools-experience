require 'rails_helper'

describe Bookings::SchoolSync do
  subject { described_class.new(email_override: email_override) }

  let(:email_override) { 'test@test.org' }

  specify { expect(subject.email_override).to eql(email_override) }
  specify { expect(subject).to respond_to(:sync) }

  context 'when syncing is disabled' do
    before do
      allow(subject).to receive_messages(sync_disabled?: true, import_and_update: true)
      allow(Rails.logger).to receive(:warn).and_return(true)
      subject.sync
    end

    let(:disabled_message) { 'GIAS sync attempted but disabled' }

    specify 'calling sync should print a warning to the log' do
      expect(Rails.logger).to have_received(:warn).with(disabled_message)
    end

    specify 'the sync should not go ahead' do
      expect(subject).not_to have_received(:import_and_update)
    end
  end

  context 'when GIAS_SYNC_DISABLED is boolean' do
    context 'when true' do
      before do
        allow(ENV).to receive(:fetch).and_return(true)
      end

      specify 'sync_disabled? should be true' do
        expect(subject.send(:sync_disabled?)).to be true
      end
    end

    context 'when false' do
      before do
        allow(ENV).to receive(:fetch).and_return(false)
      end

      specify 'sync_disabled? should be false' do
        expect(subject.send(:sync_disabled?)).to be false
      end
    end
  end
end
