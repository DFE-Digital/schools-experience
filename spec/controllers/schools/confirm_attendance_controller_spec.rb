require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ConfirmAttendanceController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by(urn: urn) }
  let!(:profile) { create(:bookings_profile, school: school) }
  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end

  describe '#show' do
    subject { get(schools_confirm_attendance_path) }
    it 'renders the show template' do
      expect(subject).to render_template(:show)
    end
  end

  describe '#update' do
    before do
      allow(Bookings::Gitis::SchoolExperience).to \
        receive(:from_booking) { school_experience }

      allow(school_experience).to \
        receive(:write_to_gitis_contact)

      ids = [
        unattended.candidate.gitis_uuid,
        attended.candidate.gitis_uuid,
      ]
      allow_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:get_schools_experience_sign_ups).with(ids) do
          [
            build(:api_schools_experience_sign_up),
            build(:api_schools_experience_sign_up)
          ]
        end
    end

    let!(:attended) do
      build(:bookings_booking, :accepted, bookings_school: school, date: 3.days.ago).tap do |bb|
        bb.save(validate: false)
      end
    end

    let!(:unattended) do
      build(:bookings_booking, :accepted, bookings_school: school, date: 2.days.ago).tap do |bb|
        bb.save(validate: false)
      end
    end

    subject! do
      put(
        schools_confirm_attendance_path,
        params: {
          attended.id.to_s => 'true',
          unattended.id.to_s => 'false',
        }
      )
    end

    specify 'should set the attended record attended' do
      expect(attended.reload.attended).to be(true)
    end

    specify 'should set the unattended record to not attended' do
      expect(unattended.reload.attended).to be(false)
    end

    specify 'should redirect to the dashboard' do
      expect(subject).to redirect_to(schools_dashboard_path)
    end

    context "when attended" do
      it 'creates a school experience and sends it to the API' do
        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_booking).with(instance_of(Bookings::Booking), :completed)
        expect(school_experience).to \
          have_received(:write_to_gitis_contact).with(attended.contact_uuid)
      end
    end

    context "when did not attend" do
      it 'creates a school experience and sends it to the API' do
        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_booking).with(instance_of(Bookings::Booking), :did_not_attend)
        expect(school_experience).to \
          have_received(:write_to_gitis_contact).with(attended.contact_uuid)
      end
    end
  end
end
