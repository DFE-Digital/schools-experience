require 'rails_helper'

describe Cron::Reminders::NextWeek, type: :job do
  specify 'should have a schedule of daily at 02:35' do
    expect(described_class.cron_expression).to eql('35 2 * * *')
  end

  describe '#time_until_booking' do
    specify { expect(subject.time_until_booking).to eql('one week') }
  end

  describe '#perform' do
    before do
      allow_any_instance_of(Cron::Reminders::NextWeek).to receive(:bookings).and_return(%w(a b c))
      allow(Bookings::ReminderBuilder).to receive(:perform_later).and_return(true)
    end

    subject! { described_class.new.perform }

    specify 'calling perform should call Bookings::Reminder.new.enqueue' do
      expect(Bookings::ReminderBuilder).to have_received(:perform_later).exactly(3).times
    end
  end
end
