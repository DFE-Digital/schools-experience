require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PreviousBookingsController, type: :request do
  include_context "logged in DfE user"
  include_context "fake gitis"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 2)
      create(:bookings_profile, school: s)
    end
  end

  describe '#index' do
    before do
      create_list(:bookings_booking, 3, :previous, :accepted, bookings_school: school)
      get schools_previous_bookings_path
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template('index') }
  end

  describe '#show' do
    let(:booking) { create :bookings_booking, :previous, :accepted, bookings_school: school }
    before { get schools_previous_booking_path(booking) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template('show') }
  end
end
