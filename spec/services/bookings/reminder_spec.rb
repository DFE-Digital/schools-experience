require 'rails_helper'

describe Bookings::Reminder, type: :request do
  include ActiveJob::TestHelper

  let(:time_until_booking) { '3 weeks' }
  let(:time_until_booking_descriptive) { 'in 3 weeks' }
  let(:school) { create(:bookings_school, :onboarded) }
  let(:booking) { create(:bookings_booking, :accepted, bookings_school: school, date: 3.weeks.from_now) }

  subject { Bookings::Reminder.new(booking, time_until_booking, time_until_booking_descriptive) }

  before { allow(Feature).to receive(:enabled?).with(:sms) { true } }

  describe '#deliver' do
    it "queues an email and sms per provided booking" do
      sign_up = build(:api_schools_experience_sign_up_with_name)

      expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:get_schools_experience_sign_up).with(booking.contact_uuid) { sign_up }

      expect { subject.deliver }.to change { enqueued_jobs.size }.by(2)
    end

    context "when it's an in school experience" do
      it "despatches the in school reminder email" do
        expect_any_instance_of(NotifyEmail::CandidateBookingReminder).to \
          receive(:despatch_later!)

        subject.deliver
      end
    end

    context "when it's a virtual experience" do
      let(:booking) { create(:bookings_booking, :accepted, :virtual_experience, bookings_school: school, date: 3.weeks.from_now) }

      it "despatches the virtual reminder email" do
        expect_any_instance_of(NotifyEmail::CandidateVirtualExperienceBookingReminder).to \
          receive(:despatch_later!)

        subject.deliver
      end
    end
  end
end
