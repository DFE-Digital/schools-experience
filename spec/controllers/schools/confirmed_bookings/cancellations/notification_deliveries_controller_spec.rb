require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ConfirmedBookings::Cancellations::NotificationDeliveriesController, type: :request do
  include_context "logged in DfE user"
  include_context "stubbed out Gitis"
  include_context "restricted unless school onboarded"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 5)
      create(:bookings_profile, school: s)
    end
  end

  let :candidate_request_rejection_notification do
    double NotifyEmail::CandidateBookingSchoolCancelsBooking,
      despatch_later!: true
  end

  before do
    allow(NotifyEmail::CandidateBookingSchoolCancelsBooking).to receive(:new) do
      candidate_request_rejection_notification
    end
  end

  context '#create' do
    before do
      post schools_booking_cancellation_notification_delivery_path \
        booking
    end

    context 'when request already closed' do
      let :placement_request do
        create :placement_request, :cancelled_by_school, school: school
      end

      let!(:booking) do
        create(:bookings_booking, bookings_placement_request: placement_request, bookings_school: school)
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_booking_cancellation_notification_delivery_path(booking)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create \
          :placement_request, :with_school_cancellation, school: school
      end

      let :cancellation do
        placement_request.school_cancellation
      end

      let!(:booking) do
        create(:bookings_booking, bookings_placement_request: placement_request, bookings_school: school)
      end

      it 'notifies the candidate' do
        expect(NotifyEmail::CandidateBookingSchoolCancelsBooking).to have_received(:new).with \
          to: cancellation.candidate_email,
          school_name: cancellation.school_name,
          candidate_name: cancellation.candidate_name,
          rejection_reasons: cancellation.reason,
          extra_details: cancellation.extra_details,
          dates_requested: cancellation.dates_requested,
          school_search_url: new_candidates_school_search_url

        expect(candidate_request_rejection_notification).to \
          have_received :despatch_later!
      end

      it 'updates the placement_request to closed' do
        expect(placement_request.reload).to be_closed
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          schools_booking_cancellation_notification_delivery_path \
            booking
      end
    end
  end

  context '#show' do
    let :placement_request do
      FactoryBot.create \
        :placement_request, :cancelled_by_school, school: school
    end

    let!(:booking) do
      create(:bookings_booking, bookings_placement_request: placement_request, bookings_school: school)
    end

    before do
      get schools_booking_cancellation_notification_delivery_path \
        booking
    end

    it 'assigns the cancellation' do
      expect(assigns(:cancellation)).to \
        eq placement_request.school_cancellation
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
