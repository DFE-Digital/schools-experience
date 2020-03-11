require 'rails_helper'

describe Bookings::ReminderBuilder, type: :job do
  let(:period) { 'one week' }
  let(:reminder) { double(Bookings::Reminder, enqueue: true) }
  let(:booking) { create(:bookings_booking) }
  before do
    allow(Bookings::Reminder).to receive(:new).with(booking, period).and_return(reminder)
  end

  subject { described_class.perform_now(booking, period) }

  context '#perform' do
    before { subject }

    specify 'should build a new reminder with the correct params' do
      expect(Bookings::Reminder).to have_received(:new).with(booking, period)
    end

    specify 'should enqueue the reminder' do
      expect(reminder).to have_received(:enqueue)
    end
  end
end
