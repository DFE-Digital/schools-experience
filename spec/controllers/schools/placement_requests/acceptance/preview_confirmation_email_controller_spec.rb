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
      allow(NotifyEmail::CandidateBookingConfirmation).to(
        receive(:from_booking)
          .and_return(double(NotifyEmail::CandidateBookingConfirmation, despatch_later!: true))
      )
    end

    let(:params) { { bookings_booking: { candidate_instructions: 'Come to the main reception' } } }

    before { patch schools_placement_request_acceptance_preview_confirmation_email_path(pr.id, params) }

    specify 'should send a candidate booking confirmation notification email' do
      expect(NotifyEmail::CandidateBookingConfirmation).to have_received(:from_booking)
    end

    specify 'should set the accepted_at time on the booking' do
      expect(booking.reload.accepted_at).not_to be_nil
    end

    specify 'should be redirected to the placement requests index' do
      expect(response).to redirect_to schools_placement_request_acceptance_email_sent_path(pr.id)
    end
  end
end
