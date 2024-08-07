require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ConfirmedBookings::Cancellations::NotificationDeliveriesController, type: :request do
  include_context "logged in DfE user"
  include_context "Degree subject autocomplete enabled"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 5)
      create(:bookings_profile, school: s)
    end
  end

  let :candidate_request_rejection_notification_email do
    double NotifyEmail::CandidateBookingSchoolCancelsBooking,
      despatch_later!: true
  end

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end

  let :candidate_request_rejection_notification_sms do
    double NotifySms::CandidateBookingSchoolCancelsBooking,
      despatch_later!: true
  end

  before do
    allow(NotifyEmail::CandidateBookingSchoolCancelsBooking).to receive(:new) do
      candidate_request_rejection_notification_email
    end

    allow(Bookings::Gitis::SchoolExperience).to \
      receive(:from_cancellation) { school_experience }

    allow(school_experience).to \
      receive(:write_to_gitis_contact)

    allow(NotifySms::CandidateBookingSchoolCancelsBooking).to receive(:new) do
      candidate_request_rejection_notification_sms
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

      it 'does not send a school experience to the API' do
        expect(school_experience).not_to \
          have_received(:write_to_gitis_contact)
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

      let(:gitis_contact) do
        api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
        api.get_schools_experience_sign_up(placement_request.contact_uuid)
      end

      it 'notifies the candidate' do
        full_name = "#{gitis_contact.first_name} #{gitis_contact.last_name}"

        expect(NotifyEmail::CandidateBookingSchoolCancelsBooking).to have_received(:new).with \
          to: gitis_contact.email,
          school_name: cancellation.school_name,
          candidate_name: full_name,
          rejection_reasons: cancellation.reason,
          extra_details: cancellation.extra_details,
          dates_requested: cancellation.dates_requested,
          school_search_url: new_candidates_school_search_url

        expect(NotifySms::CandidateBookingSchoolCancelsBooking).to have_received(:new).with \
          to: gitis_contact.telephone,
          school_name: cancellation.school_name,
          dates_requested: cancellation.dates_requested

        expect(candidate_request_rejection_notification_email).to \
          have_received :despatch_later!

        expect(candidate_request_rejection_notification_sms).to \
          have_received :despatch_later!
      end

      it 'updates the placement_request to closed' do
        expect(placement_request.reload).to be_closed
      end

      it 'creates a school experience and sends it to the API' do
        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_cancellation).with(instance_of(Bookings::PlacementRequest::Cancellation), :cancelled_by_school)

        expect(school_experience).to \
          have_received(:write_to_gitis_contact).with(placement_request.contact_uuid)
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
