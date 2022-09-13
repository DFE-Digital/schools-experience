require 'rails_helper'

describe Cron::SyncSchoolsJob, type: :job do
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
