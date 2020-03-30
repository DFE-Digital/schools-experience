require 'rails_helper'

describe Cron::RemoveCandidateSessionTokens, type: :job do
  specify 'should have a schedule of daily at 01:30' do
    expect(described_class.cron_expression).to eql('30 1 * * *')
  end

  describe '#perform' do
    before do
      allow(Candidates::SessionToken).to receive(:remove_old!).and_return true
    end

    subject! { described_class.new.perform }

    specify 'calling perform should call Bookings::SchoolSync.new.sync' do
      expect(Candidates::SessionToken).to have_received(:remove_old!)
    end
  end
end
