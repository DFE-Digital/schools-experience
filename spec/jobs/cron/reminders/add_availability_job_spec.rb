require 'rails_helper'

describe Cron::Reminders::AddAvailabilityJob, type: :job do
  describe '#perform' do
    let(:reminder_email_double) { instance_double(NotifyEmail::SchoolAddAvailabilityReminder, despatch_later!: true) }
    let(:admin_contact_email) { "admin@email.com" }

    before do
      create(:bookings_profile, created_at: DateTime.yesterday.midday)
      create(:bookings_profile, created_at: DateTime.yesterday.midday, school: create(:bookings_school, :without_availability),
                                admin_contact_email: admin_contact_email)
      create(:bookings_profile, created_at: Date.today, school: create(:bookings_school, :without_availability))

      allow(NotifyEmail::SchoolAddAvailabilityReminder).to receive(:new).with(to: admin_contact_email) do
        reminder_email_double
      end
    end

    subject! { described_class.new.perform }

    it 'sends a reminder email to all schools who created their profile yesterday and have no availability' do
      expect(reminder_email_double).to have_received(:despatch_later!).once
    end
  end
end
