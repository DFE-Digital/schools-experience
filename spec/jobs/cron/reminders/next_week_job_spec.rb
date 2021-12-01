require 'rails_helper'

describe Cron::Reminders::NextWeekJob, type: :job do
  specify 'should have a schedule of daily at 02:35' do
    expect(described_class.cron_expression).to eql('35 2 * * *')
  end

  describe '#time_until_booking' do
    specify { expect(subject.time_until_booking).to eql('one week') }
  end

  describe '#perform' do
    let :candidate_reminder_sms do
      double NotifySms::CandidateBookingReminder, despatch_later!: true
    end

    let(:accepted_bookings_in_1_week) do
      [
        FactoryBot.create(:bookings_booking, :accepted, date: 7.days.from_now.to_date),
        FactoryBot.create(:bookings_booking, :accepted, date: 7.days.from_now.to_date)
      ]
    end

    let(:number_of_accepted_bookings_in_1_week) { accepted_bookings_in_1_week.length }

    before do
      accepted_bookings_in_1_week
      FactoryBot.create(:bookings_booking, :accepted, date: 5.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, :accepted, date: 8.days.from_now.to_date)
      FactoryBot.create(:bookings_booking, date: 7.days.from_now.to_date)

      allow(NotifySms::CandidateBookingReminder).to \
        receive(:new) { candidate_reminder_sms }

      allow(Bookings::ReminderJob).to receive(:perform_later).and_return(true)
    end

    subject! { described_class.new.perform }

    specify 'should schedule Bookings::ReminderJob for accepted bookings' do
      expect(Bookings::ReminderJob).to have_received(:perform_later)
                                         .exactly(number_of_accepted_bookings_in_1_week).times
    end

    it 'despatches SMS reminders' do
      accepted_bookings_in_1_week.each do |booking|
        expect(
          NotifySms::CandidateBookingReminder
        ).to have_received(:new).with(
          to: booking.contact_number,
          school_name: booking.bookings_school,
          time_until_booking: 'one week'
        )
      end

      expect(
        candidate_reminder_sms
      ).to have_received(:despatch_later!).exactly(number_of_accepted_bookings_in_1_week).times
    end
  end
end
