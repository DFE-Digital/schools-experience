require 'rails_helper'

describe Bookings::SchoolSync do
  let(:email_override) { 'test@test.org' }
  subject { described_class.new(email_override: email_override) }

  specify { expect(subject.email_override).to eql(email_override) }
  specify { expect(subject).to respond_to(:sync) }

  context 'when syncing is disabled' do
    before do
      allow(subject).to receive(:sync_disabled?).and_return(true)
      allow(subject).to receive(:import_and_update).and_return(true)
      allow(Rails.logger).to receive(:warn).and_return(true)
    end

    let(:disabled_message) { 'GIAS sync attempted but disabled' }

    before { subject.sync }

    specify 'calling sync should print a warning to the log' do
      expect(Rails.logger).to have_received(:warn).with(disabled_message)
    end

    specify 'the sync should not go ahead' do
      expect(subject).not_to have_received(:import_and_update)
    end
  end
end
