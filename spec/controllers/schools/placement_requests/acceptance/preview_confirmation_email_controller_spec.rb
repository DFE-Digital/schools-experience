require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::PreviewConfirmationEmailController, type: :request do
  include_context "logged in DfE user"

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end
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

  context '#edit' do
    before do
      get edit_schools_placement_request_acceptance_preview_confirmation_email_path(pr.id)
    end

    specify('renders the edit template') { expect(response).to render_template(:edit) }

    specify "the booking's accepted_at time should be nil" do
      expect(booking.reload.accepted_at).to be_nil
    end
  end

  context '#update' do
    before do
      allow(Bookings::Gitis::SchoolExperience).to \
        receive(:from_booking) { school_experience }

      allow(school_experience).to \
        receive(:write_to_gitis_contact)

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

    context 'when virtual experience' do
      let!(:virtual_experience) { create(:bookings_placement_date, virtual: true) }
      let!(:pr) { create(:placement_request, :virtual, school: @current_user_school, placement_date: virtual_experience) }
      let!(:booking) do
        create(
          :bookings_booking,
          bookings_school: @current_user_school,
          experience_type: 'virtual',
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

      specify 'should send a candidate booking confirmation notification virtual experience email' do
        allow(NotifyEmail::CandidateVirtualExperienceBookingConfirmation).to(
          receive(:from_booking)
            .and_return(double(NotifyEmail::CandidateVirtualExperienceBookingConfirmation, despatch_later!: true))
        )

        patch schools_placement_request_acceptance_preview_confirmation_email_path(pr.id, params)

        expect(NotifyEmail::CandidateVirtualExperienceBookingConfirmation).to have_received(:from_booking)
      end
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

    specify 'creates a school experience and sends it to the API' do
      expect(Bookings::Gitis::SchoolExperience).to \
        have_received(:from_booking).with(instance_of(Bookings::Booking), :confirmed)
      expect(school_experience).to \
        have_received(:write_to_gitis_contact).with(pr.booking.contact_uuid)
    end

    specify 'should be redirected to the placement requests index' do
      expect(response).to redirect_to schools_placement_request_acceptance_email_sent_path(pr.id)
    end
  end
end
