require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::AddMoreDetailsController, type: :request do
  include_context "logged in DfE user"
  include_context "restricted unless school onboarded"

  let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
  let!(:booking) do
    create(
      :bookings_booking,
      bookings_school: @current_user_school,
      bookings_placement_request: pr,
      date: 3.weeks.from_now,
      placement_details: "an amazing experience"
    )
  end

  let!(:profile) do
    create(:bookings_profile, school: @current_user_school)
  end

  context '#new' do
    before do
      get new_schools_placement_request_acceptance_add_more_details_path(pr.id)
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
        )
      end

      specify "should redirect to previous step" do
        expect(response).to redirect_to(
          new_schools_placement_request_acceptance_confirm_booking_path
        )
      end
    end
  end

  context '#create' do
    before { post schools_placement_request_acceptance_add_more_details_path(pr.id, params: params) }

    let(:contact_name) { "Edna Krabappel" }
    let(:contact_number) { "01234 456 678" }
    let(:contact_email) { "edna.krabappel@springfield.edu" }
    let(:location) { "Reception" }

    context 'with valid params' do
      let(:params) do
        {
          schools_placement_requests_add_more_details: {
            contact_name: contact_name,
            contact_number: contact_number,
            contact_email: contact_email,
            location: location
          }
        }
      end

      before { booking.reload }

      specify 'should add supplied params to a booking' do
        expect(booking.contact_name).to eql(contact_name)
        expect(booking.contact_number).to eql(contact_number)
        expect(booking.contact_email).to eql(contact_email)
        expect(booking.location).to eql(location)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          schools_placement_requests_add_more_details: {
            contact_name: contact_name,
            # contact_number: contact_number,
            contact_email: contact_email,
            location: location
          }
        }
      end

      specify 'should rerender the new template' do
        expect(response).to render_template(:new)
      end

      before { booking.reload }

      specify 'should not update the booking' do
        %i(contact_name contact_number contact_email location).each do |attribute|
          expect(booking.send(attribute)).to be_nil
        end
      end
    end
  end
end
