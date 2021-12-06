require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::CancelledBookingsController, type: :request do
  include_context "logged in DfE user"

  let! :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 2)
      create(:bookings_profile, school: s)
    end
  end

  describe '#index' do
    let(:cancelled_by_school) { create_list(:bookings_booking, 3, :cancelled_by_school, bookings_school: school) }
    let(:cancelled_by_candidate) { create_list(:bookings_booking, 2, :cancelled_by_candidate, bookings_school: school) }
    before { get schools_cancelled_bookings_path }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:index) }

    it 'assigns the correct bookings' do
      expect(assigns(:bookings)).to eq cancelled_by_school + cancelled_by_candidate
    end
  end

  describe '#show' do
    let(:cancelled_booking) { create :bookings_booking, :cancelled_by_school, bookings_school: school }
    before { get schools_cancelled_booking_path(cancelled_booking) }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:show) }

    it 'assigns the correct booking' do
      expect(assigns(:booking)).to eq cancelled_booking
    end
  end
end
