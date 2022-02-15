require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::MakeChangesController, type: :request do
  include_context "logged in DfE user"

  let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }

  let!(:profile) do
    create(:bookings_profile, school: @current_user_school)
  end

  context '#new' do
    before do
      get new_schools_placement_request_acceptance_make_changes_path(pr.id)
    end

    specify 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  context '#create' do
    before { post schools_placement_request_acceptance_make_changes_path(pr.id, params: params) }

    let(:future_date) { 3.weeks.from_now.to_date }
    let(:bookings_subject) { create(:bookings_subject) }
    let(:contact_name) { "Edna Krabappel" }
    let(:contact_number) { "01234 456 678" }
    let(:contact_email) { "edna.krabappel@springfield.edu" }
    let(:location) { "Reception" }

    context 'with valid params' do
      let(:params) do
        {
          bookings_booking: {
            date: future_date,
            bookings_subject_id: bookings_subject.id,
            contact_name: contact_name,
            contact_number: contact_number,
            contact_email: contact_email
          }
        }
      end

      subject { Bookings::Booking.last }

      specify 'should add supplied params to a booking' do
        expect(subject.date).to eql(future_date)
        expect(subject.bookings_subject_id).to eql(bookings_subject.id)
        expect(subject.contact_name).to eql(contact_name)
        expect(subject.contact_number).to eql(contact_number)
        expect(subject.contact_email).to eql(contact_email)
      end
    end

    context 'with invalid params' do
      let(:past_date) { 3.weeks.ago.to_date }
      let(:params) do
        {
          bookings_booking: {
            date: past_date,
            bookings_subject_id: bookings_subject.id,
            contact_name: contact_name,
            contact_number: contact_number,
            contact_email: contact_email
          }
        }
      end

      specify 'should rerender the new template' do
        expect(response).to render_template(:new)
      end

      specify 'should not update the booking' do
        expect(Bookings::Booking.all).to be_empty
      end
    end
  end
end
