require 'rails_helper'

describe NotifyEmail::CandidateBookingConfirmation do
  it_should_behave_like "email template", "f66aaa08-df33-4be6-95b6-7e1cf8595a2b",
    school_name: "Springfield Elementary",
    candidate_name: "Kearney Zzyzwicz",
    placement_schedule: "2022-03-04 for 3 days",
    school_address: "123 Main Street, Springfield, M2 3JF",
    school_start_time: "08:40",
    school_finish_time: "15:30",
    school_dress_code: "Smart casual, elbow patches",
    school_parking: "There is a car park on the school grounds",
    school_admin_email: "sskinner@springfield.co.uk",
    school_admin_telephone: "01234 123 1234",
    school_teacher_name: "Edna Krabappel",
    school_teacher_email: "ednak@springfield.co.uk",
    school_teacher_telephone: "01234 234 1245",
    placement_details: "You will shadow a teacher and assist with lesson planning",
    candidate_instructions: "Report to reception on arrival",
    subject_name: "Biology",
    cancellation_url: 'https://example.com/candiates/cancel/abc-123'

  describe ".from_booking" do
    before do
      stub_const(
        'Notify::API_KEY',
        ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
      )
    end

    specify { expect(described_class).to respond_to(:from_booking) }

    let!(:school) { create(:bookings_school, urn: 11_048) }
    let!(:profile) { create(:bookings_profile, school: school) }
    let(:to) { "morris.szyslak@moes.net" }
    let(:candidate_name) { "morris.szyslak" }

    let!(:pr) { create(:bookings_placement_request, school: school) }
    let!(:booking) do
      create :bookings_booking, :accepted, bookings_placement_request: pr
    end

    let!(:cancellation_url) { "https://example.com/candidates/cancel/#{booking.token}" }

    subject { described_class.from_booking(to, candidate_name, booking, cancellation_url) }

    it { is_expected.to be_a(described_class) }

    context 'correctly assigning attributes' do
      specify 'candidate_name is correctly-assigned' do
        expect(subject.candidate_name).to eql(candidate_name)
      end

      specify 'placement_schedule is correctly-assigned' do
        expect(subject.placement_schedule).to eql(booking.placement_start_date_with_duration)
      end

      specify 'school_address is correctly-assigned' do
        expect(subject.school_address).to eql(
          [school.address_1,
           school.address_2,
           school.address_3,
           school.town,
           school.county,
           school.postcode].reject(&:blank?).join(", ")
        )
      end

      specify 'school_start_time is correctly-assigned' do
        expect(subject.school_start_time).to eql(profile.start_time)
      end

      specify 'school_end_time is correctly-assigned' do
        expect(subject.school_finish_time).to eql(profile.end_time)
      end

      specify 'school_dress_code is correctly-assigned' do
        expect(subject.school_dress_code).to eql(
          [profile.dress_code, profile.dress_code_other_details].reject(&:blank?).join(", ")
        )
      end

      specify 'school_parking is correctly-assigned' do
        expect(subject.school_parking).to eql(
          ['No', profile.parking_details].join(', ')
        )
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

      context 'when the profile experience details is missing' do
        let!(:profile) { create(:bookings_profile, experience_details: nil, school: school) }

        specify 'placement_details is assigned to empty string' do
          expect(subject.placement_details).to eql ''
        end
      end

      specify 'placement_details is correctly-assigned' do
        expect(subject.placement_details).to eql(school.profile.experience_details)
      end

      specify 'candidate_instructions are correctly-assigned' do
        expect(subject.candidate_instructions).to eql(booking.candidate_instructions)
      end

      specify 'subject_name is correctly-assigned' do
        expect(subject.subject_name).to eql(booking.bookings_subject.name)
      end

      specify 'cancellation_url is correctly-assigned' do
        expect(subject.cancellation_url).to eql(cancellation_url)
      end
    end
  end
end
