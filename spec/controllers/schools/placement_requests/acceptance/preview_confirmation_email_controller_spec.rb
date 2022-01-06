require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::PreviewConfirmationEmailController, type: :request do
  include_context "logged in DfE user"

  let!(:booking_profile) { create(:bookings_profile, school: @current_user_school) }
  let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
  let!(:booking) do
    create(
      :bookings_booking,
      bookings_school: @current_user_school,
      bookings_placement_request: pr,
      date: 3.weeks.from_now,
      placement_details: "an amazing experience",
      contact_name: 'Gary Chalmers',
      contact_email: 'gary.chalmers@springfield.edu',
      contact_number: '01234 456 678',
      location: 'Near the assembly hall',
      candidate_instructions: 'Please come to the main reception'
    )
  end
  let :candidate_booking_confirmation_sms do
    double NotifySms::CandidateBookingConfirmation,
           despatch_later!: true
  end
  let(:gitis_contact) do
    api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
    api.get_schools_experience_sign_up(pr.contact_uuid)
  end

  context '#new' do
    before do
      get edit_schools_placement_request_acceptance_preview_confirmation_email_path(pr.id)
    end

    specify('renders the edit template') { expect(response).to render_template(:edit) }

    specify "the booking's accepted_at time should be nil" do
      expect(booking.reload.accepted_at).to be_nil
    end
  end

  context '#create' do
    before do
      allow(Bookings::Gitis::EventLogger).to receive(:write_later).and_return(true)

      allow(NotifyEmail::CandidateBookingConfirmation).to(
        receive(:from_booking)
          .and_return(double(NotifyEmail::CandidateBookingConfirmation, despatch_later!: true))
      )

      allow(NotifySms::CandidateBookingConfirmation).to receive(:new) do
        candidate_booking_confirmation_sms
      end
    end

    let(:params) { { bookings_booking: { candidate_instructions: 'Come to the main reception' } } }

    before { patch schools_placement_request_acceptance_preview_confirmation_email_path(pr.id, params) }

    specify 'should send a candidate booking confirmation notification email' do
      expect(NotifyEmail::CandidateBookingConfirmation).to have_received(:from_booking)
    end

    specify 'sends a candidate booking confirmation sms' do
      expect(NotifySms::CandidateBookingConfirmation).to have_received(:new).with \
        to: gitis_contact.telephone,
        school_name: booking.bookings_school.name,
        dates_requested: booking.date.to_formatted_s(:govuk),
        cancellation_url: candidates_cancel_url(booking.token)

      expect(candidate_booking_confirmation_sms).to \
        have_received :despatch_later!
    end

    specify 'should set the accepted_at time on the booking' do
      expect(booking.reload.accepted_at).not_to be_nil
    end

    specify 'should enqueue a log to gitis job' do
      expect(Bookings::Gitis::EventLogger).to \
        have_received(:write_later).with pr.contact_uuid, :booking, instance_of(Bookings::Booking)
    end

    specify 'should be redirected to the placement requests index' do
      expect(response).to redirect_to schools_placement_request_acceptance_email_sent_path(pr.id)
    end
  end
end
