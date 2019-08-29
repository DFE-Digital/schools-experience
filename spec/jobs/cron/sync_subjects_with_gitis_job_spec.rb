require 'rails_helper'

describe Cron::SyncSubjectsWithGitisJob, type: :job do
#  specify 'should have a schedule of daily at 03:30' do
#    expect(described_class.cron_expression).to eql('30 3 * * *')
#  end

  describe '#perform' do
    before do
      allow(Bookings::SubjectSync).to receive(:synchronise).and_return(true)
    end

    subject! { described_class.new.perform }

    specify 'calling perform should call Bookings::SchoolSync.new.sync' do
      expect(Bookings::SubjectSync).to have_received(:synchronise)
    end
  end
end
