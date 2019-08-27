require 'rails_helper'

describe Cron::SyncSchoolsJob, type: :job do
  specify 'should have a schedule of daily at 04:30' do
    expect(described_class.cron_expression).to eql('30 4 * * *')
  end

  describe '#perform' do
    let(:school_sync_instance) { double Object, sync: true }

    before do
      allow(Bookings::SchoolSync).to receive(:new).and_return(school_sync_instance)
    end

    subject! { described_class.new.perform }

    specify 'calling perform should call Bookings::SchoolSync.new.sync' do
      expect(school_sync_instance).to have_received(:sync)
    end
  end
end
