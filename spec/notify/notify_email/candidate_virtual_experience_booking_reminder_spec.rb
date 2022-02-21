require 'rails_helper'

describe NotifyEmail::CandidateVirtualExperienceBookingReminder do
  it_should_behave_like "email template", "be4eb8b2-3abd-4882-8719-e6812975110a",
    time_until_booking: "2 weeks",
    school_name: "Springfield Elementary",
    candidate_name: "Kearney Zzyzwicz",
    placement_schedule: "2022-03-04 for 3 days",
    school_start_time: "08:40",
    school_finish_time: "15:30",
    school_admin_email: "sskinner@example.com",
    school_admin_telephone: "01234 123 1234",
    school_teacher_name: "Edna Krabappel",
    school_teacher_email: "ednak@example.com",
    school_teacher_telephone: "01234 234 1245",
    candidate_instructions: "Please report to reception on arrival",
    subject_name: 'Biology',
    cancellation_url: "#{Rails.configuration.x.base_url}/candiates/cancel/abc-123"

  describe ".from_booking" do
    before do
      stub_const(
        'Notify::API_KEY',
        ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
      )
    end

    specify { expect(described_class).to respond_to(:from_booking) }

    let(:time_until_booking) { "2 weeks" }
    let!(:school) { create(:bookings_school) }
    let!(:profile) { create(:bookings_profile, school: school) }
    let(:to) { "morris.szyslak@moes.net" }
    let(:candidate_name) { "morris.szyslak" }

    let!(:pr) { create(:bookings_placement_request, school: school) }
    let!(:booking) do
      create(
        :bookings_booking,
        bookings_school: school,
        bookings_placement_request: pr
      )
    end

    before do
      allow(booking).to receive(:candidate_name).and_return(candidate_name)
    end

    let!(:cancellation_url) { "#{Rails.configuration.x.base_url}/candidates/cancel/#{booking.token}" }

    subject { described_class.from_booking(to, time_until_booking, booking, cancellation_url) }

    it { is_expected.to be_a(described_class) }

    context 'correctly assigning attributes' do
      specify 'time_until_booking is correctly assigned' do
        expect(subject.time_until_booking).to eql(time_until_booking)
      end

      specify 'candidate_name is correctly-assigned' do
        expect(subject.candidate_name).to eql(candidate_name)
      end

      specify 'placement_schedule is correctly-assigned' do
        expect(subject.placement_schedule).to eql(booking.placement_start_date_with_duration)
      end

      specify 'school_start_time is correctly-assigned' do
        expect(subject.school_start_time).to eql(profile.start_time)
      end

      specify 'school_end_time is correctly-assigned' do
        expect(subject.school_finish_time).to eql(profile.end_time)
      end

      specify 'school_admin_email is correctly-assigned' do
        expect(subject.school_admin_email).to eql(profile.admin_contact_email)
      end

      specify 'school_admin_telephone is correctly-assigned' do
        expect(subject.school_admin_telephone).to eql(profile.admin_contact_phone)
      end

      specify 'school_teacher_name is correctly-assigned' do
        expect(subject.school_teacher_name).to eql(booking.contact_name)
      end

      specify 'school_teacher_email is correctly-assigned' do
        expect(subject.school_teacher_email).to eql(booking.contact_email)
      end

      specify 'school_teacher_telephone is correctly-assigned' do
        expect(subject.school_teacher_telephone).to eql(booking.contact_number)
      end

      specify 'subject_name is correctly-assigned' do
        expect(subject.subject_name).to eql(booking.bookings_subject.name)
      end

      specify 'candidate_instructions is correctly-assigned' do
        expect(subject.candidate_instructions).to eql(booking.candidate_instructions)
      end

      specify 'cancellation_url is correctly-assigned' do
        expect(subject.cancellation_url).to eql(cancellation_url)
      end
    end
  end
end
