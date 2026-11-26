require 'rails_helper'

describe Bookings::SchoolSync do
  subject(:school_sync) { described_class.new(email_override: email_override) }

  let(:email_override) { 'test@test.org' }

  specify { expect(school_sync.email_override).to eql(email_override) }
  specify { expect(school_sync).to respond_to(:sync) }

  context 'when syncing is disabled' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('GIAS_SYNC_DISABLED', false).and_return(true)
      allow(Rails.logger).to receive(:warn).and_return(true)
      allow(Bookings::Data::GiasDataFile).to receive(:new).and_call_original
    end

    let(:disabled_message) { 'GIAS sync attempted but disabled' }

    specify 'calling sync should print a warning to the log' do
      school_sync.sync
      expect(Rails.logger).to have_received(:warn).with(disabled_message)
    end

    specify 'the sync should not go ahead' do
      school_sync.sync

      expect(Bookings::Data::GiasDataFile).not_to have_received(:new)
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
