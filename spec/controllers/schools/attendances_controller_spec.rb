require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::AttendancesController, type: :request do
  include_context "logged in DfE user"
  include_context "fake gitis"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      create(:bookings_profile, school: s)
    end
  end

  let! :booking do
    create :bookings_booking, :previous, :accepted, :attended,
      bookings_placement_request: create(:bookings_placement_request, school: school),
      bookings_school: school
  end

  describe '#index' do
    subject {
      get schools_attendances_path
      response
    }

    it { is_expected.to have_http_status :success }
    it { is_expected.to have_rendered 'index' }
  end
end
