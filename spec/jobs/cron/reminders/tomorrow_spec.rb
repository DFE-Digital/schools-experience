require 'rails_helper'

describe Cron::Reminders::Tomorrow, type: :job do
  specify 'should have a schedule of daily at 02:30' do
    expect(described_class.cron_expression).to eql('30 2 * * *')
  end

  describe '#time_until_booking' do
    specify { expect(subject.time_until_booking).to eql('one day') }
  end

  describe '#perform' do
    let(:reminder_instance) { double Bookings::Reminder, enqueue: true }

    before do
      allow(Bookings::Reminder).to receive(:new).and_return(reminder_instance)
    end

    subject! { described_class.new.perform }

    specify 'calling perform should call Bookings::Reminder.new.enqueue' do
      expect(reminder_instance).to have_received(:enqueue)
    end
  end
end
