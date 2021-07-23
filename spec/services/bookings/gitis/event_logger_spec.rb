require 'rails_helper'

describe Bookings::Gitis::EventLogger, type: :model do
  subject { described_class.entry log_type, log_subject }
  let(:today) { Time.zone.today }
  let(:today_str) { today.to_formatted_s(:gitis) }
  let(:padded_urn) { sprintf('%-6s', school.urn) }

  context 'with a PlacementRequest' do
    let(:log_type) { 'request' }
    let(:school) { log_subject.school }
    let(:log_subject) { create(:placement_request) }

    context 'with flexible dates' do
      it "will generate an entry" do
        is_expected.to eql \
          "#{today_str} REQUEST                           #{padded_urn} #{school.name}"
      end
    end

    context 'with fixed dates' do
      let(:date) { create(:bookings_placement_date, bookings_school: log_subject.school) }
      let(:formatted_date) { date.date.to_formatted_s(:gitis) }
      before { log_subject.update!(placement_date: date) }

      it "will generate an entry" do
        is_expected.to eql \
          "#{today_str} REQUEST                #{formatted_date} #{padded_urn} #{school.name}"
      end
    end

    describe "#classroom_experience_note" do
      subject { described_class.new(log_type, log_subject).classroom_experience_note }

      it { is_expected.to include(recordedAt: today) }
      it { is_expected.to include(action: "REQUEST") }
      it { is_expected.to include(schoolUrn: school.urn) }
      it { is_expected.to include(schoolName: school.name) }

      context "with fixed dates" do
        let(:date) { create(:bookings_placement_date, bookings_school: log_subject.school) }

        before { log_subject.update!(placement_date: date) }

        it { is_expected.to include(date: date.date) }
      end
    end
  end

  context 'with a Booking' do
    let(:log_type) { 'booking' }
    let(:log_subject) { create(:bookings_booking, :accepted) }
    let(:formatted_date) { log_subject.date.to_formatted_s(:gitis) }
    let(:school) { log_subject.bookings_school }

    it "will record confirmation of a booking" do
      is_expected.to eql \
        "#{today_str} ACCEPTED               #{formatted_date} #{padded_urn} #{school.name}"
    end

    describe "#classroom_experience_note" do
      subject { described_class.new(log_type, log_subject).classroom_experience_note }

      it { is_expected.to include(recordedAt: today) }
      it { is_expected.to include(action: "ACCEPTED") }
      it { is_expected.to include(date: log_subject.date) }
      it { is_expected.to include(schoolUrn: school.urn) }
      it { is_expected.to include(schoolName: school.name) }
    end
  end

  context 'with a Cancellation' do
    let(:log_type) { 'cancellation' }

    context 'by the Candidate of a Request' do
      let(:request) { create(:placement_request, :cancelled) }
      let(:log_subject) { request.candidate_cancellation }
      let(:school) { request.school }

      it "will record cancellation by Candidate" do
        is_expected.to eql \
          "#{today_str} CANCELLED BY CANDIDATE            #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "CANCELLED BY CANDIDATE") }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end

    context 'by the School of a Request' do
      let(:request) { create(:placement_request, :cancelled_by_school) }
      let(:log_subject) { request.school_cancellation }
      let(:school) { request.school }

      it "will record cancellation by School" do
        is_expected.to eql \
          "#{today_str} CANCELLED BY SCHOOL               #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "CANCELLED BY SCHOOL") }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end

    context 'by the Candidate of a Booking' do
      let(:booking) { create(:bookings_booking, :cancelled_by_candidate) }
      let(:school) { booking.bookings_school }
      let(:date) { booking.date.to_formatted_s(:gitis) }
      let(:log_subject) { booking.candidate_cancellation }

      it "will record cancellation by Candidate" do
        is_expected.to eql \
          "#{today_str} CANCELLED BY CANDIDATE #{date} #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "CANCELLED BY CANDIDATE") }
        it { is_expected.to include(date: booking.date) }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end

    context 'by the School of a Booking' do
      let(:booking) { create(:bookings_booking, :cancelled_by_school) }
      let(:school) { booking.bookings_school }
      let(:date) { booking.date.to_formatted_s(:gitis) }
      let(:log_subject) { booking.school_cancellation }

      it "will record cancellation by School" do
        is_expected.to eql \
          "#{today_str} CANCELLED BY SCHOOL    #{date} #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "CANCELLED BY SCHOOL") }
        it { is_expected.to include(date: booking.date) }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end
  end

  context 'with an Attendance' do
    let(:log_type) { 'attendance' }
    let(:booking) { create(:bookings_booking, :accepted) }
    let(:school) { booking.bookings_school }
    let(:date) { booking.date.to_formatted_s(:gitis) }

    context 'when they attended' do
      before { booking.update!(attended: true) }
      let(:log_subject) { booking }

      it "will record they attended" do
        is_expected.to eql \
          "#{today_str} ATTENDED               #{date} #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "ATTENDED") }
        it { is_expected.to include(date: booking.date) }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end

    context 'when they did not attend' do
      before { booking.update!(attended: false) }
      let(:log_subject) { booking }

      it "record they did not attend" do
        is_expected.to eql \
          "#{today_str} DID NOT ATTEND         #{date} #{padded_urn} #{school.name}"
      end

      describe "#classroom_experience_note" do
        subject { described_class.new(log_type, log_subject).classroom_experience_note }

        it { is_expected.to include(recordedAt: today) }
        it { is_expected.to include(action: "DID NOT ATTEND") }
        it { is_expected.to include(date: booking.date) }
        it { is_expected.to include(schoolUrn: school.urn) }
        it { is_expected.to include(schoolName: school.name) }
      end
    end
  end

  context 'with unknown type' do
    let(:log_type) { 'unknown' }
    let(:log_subject) { nil }
    it "will raise an error" do
      expect { subject }.to raise_exception(NoMethodError)
    end
  end

  context 'write_later' do
    let(:contactid) { SecureRandom.uuid }
    let(:placement_request) { create(:placement_request) }

    it "sends the classroom experience note to the API" do
      note = described_class.new(:request, placement_request).classroom_experience_note

      expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:add_classroom_experience_note).with(contactid, note)

      described_class.write_later contactid, :request, placement_request
    end
  end
end
