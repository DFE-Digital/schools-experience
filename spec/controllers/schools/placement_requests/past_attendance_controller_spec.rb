require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequests::PastAttendanceController, type: :request do
  include_context "when a DfE user is logged in"

  let(:school) { Bookings::School.find_by! urn: urn }
  let!(:profile) { create :bookings_profile, school: school }

  describe '#index' do
    subject do
      get schools_placement_request_past_attendances_path(pr.id)
      response
    end

    let(:booking) do
      create :bookings_booking, :accepted, :attended, bookings_school: school,
                                                      bookings_placement_request:
          create(:bookings_placement_request, school: school)
    end

    let(:pr) do
      create :bookings_placement_request, school: school,
                                          candidate: booking.bookings_placement_request.candidate
    end


    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template 'index' }
  end
end
