require 'rails_helper'

describe NotifyEmail::CandidateBookingConfirmation do
  include_context "stubbed out Gitis"

  it_should_behave_like "email template", "29ed44bd-dc79-4fb3-bf8e-6e0ff18365b3",
    school_name: "Springfield Elementary",
    candidate_name: "Kearney Zzyzwicz",
    placement_start_date: "2022-01-01",
    placement_finish_date: "2022-02-01",
    school_address: "123 Main Street, Springfield, M2 3JF",
    school_start_time: "08:40",
    school_finish_time: "15:30",
    school_dress_code: "Smart casual, elbow patches",
    school_parking: "There is a car park on the school grounds",
    school_admin_name: "Seymour Skinner",
    school_admin_email: "sskinner@springfield.co.uk",
    school_admin_telephone: "01234 123 1234",
    school_teacher_name: "Edna Krabappel",
    school_teacher_email: "ednak@springfield.co.uk",
    school_teacher_telephone: "01234 234 1245",
    placement_details: "You will shadow a teacher and assist with lesson planning",
    placement_fee: 30

  describe ".from_booking" do
    before do
      stub_const(
        'Notify::API_KEY',
        ["somekey", SecureRandom.uuid, SecureRandom.uuid].join("-")
      )
    end

    specify { expect(described_class).to respond_to(:from_booking) }

    let!(:school) { create(:bookings_school, urn: 11048) }
    let!(:profile) { create(:bookings_profile, school: school) }
    let(:to) { "morris.szyslak@moes.net" }

    let!(:pr) { create(:bookings_placement_request, school: school) }
    let!(:booking) do
      create(
        :bookings_booking,
        bookings_school: school,
        bookings_placement_request: pr
      )
    end

    subject { described_class.from_booking(to, booking) }

    it { is_expected.to be_a(described_class) }

    context 'correctly assigning attributes' do
      specify 'candidate_name is correctly-assigned' do
        expect(subject.candidate_name).to eql([pr.candidate.firstname, pr.candidate.lastname].join(' '))
      end

      specify 'placement_start_date is correctly-assigned' do
        expect(subject.placement_start_date).to eql(booking.date)
      end

      specify 'placement_finish_date is correctly-assigned'
      #  expect(subject.placement_finish_date).to eql('FIXME')
      #end

      specify 'school_address is correctly-assigned' do
        expect(subject.school_address).to eql(
          [school.address_1, school.address_2, school.address_3,
           school.town, school.county, school.postcode].join(", ")
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
          [profile.dress_code, profile.dress_code_other_details].join(", ")
        )
      end

      specify 'school_parking is correctly-assigned' do
        expect(subject.school_parking).to eql(
          ['No', profile.parking_details].join(', ')
        )
      end

      specify 'school_admin_name is correctly-assigned' do
        expect(subject.school_admin_name).to eql(profile.admin_contact_full_name)
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

      specify 'placement_details is correctly-assigned' do
        expect(subject.placement_details).to eql(booking.placement_details)
      end

      specify 'placement_fee is correctly-assigned'
      #  expect(subject.placement_fee).to eql('REMOVE')
      #end
    end
  end
end
