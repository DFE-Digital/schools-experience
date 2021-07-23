require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ConfirmAttendanceController, type: :request do
  include_context "logged in DfE user"

  let(:school) { Bookings::School.find_by(urn: urn) }
  let!(:profile) { create(:bookings_profile, school: school) }

  describe '#show' do
    subject { get(schools_confirm_attendance_path) }
    it 'renders the show template' do
      expect(subject).to render_template(:show)
    end
  end

  describe '#update' do
    before { allow(Bookings::Gitis::EventLogger).to receive(:write_later).and_return(true) }

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
          attended.id => 'true',
          unattended.id => 'false',
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

    specify 'should enqueue a gitis update for the attended record' do
      expect(Bookings::Gitis::EventLogger).to \
        have_received(:write_later).with \
          attended.contact_uuid, :attendance, have_attributes(attended: true)
    end

    specify 'should enqueue a gitis update for the unattended record' do
      expect(Bookings::Gitis::EventLogger).to \
        have_received(:write_later).with \
          unattended.contact_uuid, :attendance, have_attributes(attended: false)
    end
  end
end
