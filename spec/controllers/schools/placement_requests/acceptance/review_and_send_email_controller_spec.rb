require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::ReviewAndSendEmail, type: :request do
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
      location: 'Near the assembly hall'
    )
  end

  context '#new' do
    before do
      get new_schools_placement_request_acceptance_review_and_send_email_path(pr.id)
    end

    specify 'renders the new template' do
      expect(response).to render_template(:new)
    end

    context "when the previous step hasn't been completed" do
      let!(:booking) do
        create(
          :bookings_booking,
          bookings_school: @current_user_school,
          bookings_placement_request: pr,
          date: 3.weeks.from_now,
          placement_details: "an amazing experience"
        )
      end

      specify "should redirect to previous step" do
        expect(response).to redirect_to(
          new_schools_placement_request_acceptance_add_more_details_path(pr.id)
        )
      end
    end
  end

  context '#create' do
    before do
      allow(NotifyEmail::CandidateBookingConfirmation).to(
        receive(:from_booking)
          .and_return(double(NotifyEmail::CandidateRequestConfirmation, despatch_later!: true))
      )
    end

    before { post schools_placement_request_acceptance_review_and_send_email_path(pr.id, params: params) }

    let(:candidate_instructions) { "If there is nobody at reception please ring the bell" }

    context 'with valid params' do
      let(:params) do
        {
          review_and_send_email: {
            candidate_instructions: candidate_instructions
          }
        }
      end

      before { booking.reload }

      specify 'should add supplied params to a booking' do
        expect(booking.candidate_instructions).to eql(candidate_instructions)
      end

      specify 'should send a candidate booking confirmation notification email' do
        expect(NotifyEmail::CandidateBookingConfirmation).to have_received(:from_booking)
      end
    end

    context 'with invalid params' do
      let(:params) do
        { review_and_send_email: { candidate_instructions: "" } }
      end

      specify 'should rerender the new template' do
        expect(response).to render_template(:new)
      end

      before { booking.reload }

      specify 'should not update the booking' do
        %i(candidate_instructions).each do |attribute|
          expect(booking.send(attribute)).to be_nil
        end
      end
    end
  end
end
