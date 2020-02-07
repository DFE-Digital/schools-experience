require 'rails_helper'

describe Cron::Reminders::NextWeekJob, type: :job do
  specify 'should have a schedule of daily at 02:35' do
    expect(described_class.cron_expression).to eql('35 2 * * *')
  end

  describe '#time_until_booking' do
    specify { expect(subject.time_until_booking).to eql('one week') }
  end

  describe '#perform' do
    before do
      FactoryBot.create(:bookings_booking, :accepted, date: 7.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, :accepted, date: 7.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, :accepted, date: 5.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, :accepted, date: 8.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, date: 7.days.from_now.to_date)

      allow(Bookings::ReminderJob).to receive(:perform_later).and_return(true)
    end

    subject! { described_class.new.perform }

    specify 'should schedule Bookings::ReminderJob for accepted bookings' do
      expect(Bookings::ReminderJob).to have_received(:perform_later).exactly(2).times
    end
  end
end
