require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'schools', 'session_context')

describe Schools::PlacementRequests::Acceptance::ConfirmBookingController, type: :request do
  include_context "logged in DfE user"

  let!(:pr) { create(:bookings_placement_request, school: @current_user_school) }
  before { create(:bookings_profile, school: @current_user_school) }

  context '#new' do
    before do
      get new_schools_placement_request_acceptance_confirm_booking_path(pr.id)
    end

    specify 'renders the new template' do
      expect(response).to render_template(:new)
    end
  end

  context '#create' do
    let(:params) do
      {
        schools_placement_requests_confirm_booking: {
          bookings_subject_id: bookings_subject.id,
          date: date,
          placement_details: placement_details
        }
      }
    end

    subject { post schools_placement_request_acceptance_confirm_booking_path(pr.id, params: params) }

    let(:bookings_subject) { create(:bookings_subject) }
    let(:date) { 3.weeks.from_now.to_date }
    let(:placement_details) { "you'll get to try out teaching" }

    context 'with valid params' do
      before { subject }

      context 'when the placement request does not belong to a placement date' do
        specify 'should create a new booking' do
          expect(pr.booking).to be_a(Bookings::Booking)
        end

        specify 'should redirect to the add more details page' do
          expect(response).to redirect_to(new_schools_placement_request_acceptance_add_more_details_path(pr.id))
        end

        specify 'should set up the booking with the correct values' do
          pr.booking.tap do |b|
            expect(b.date).to eql(date)
            expect(b.bookings_subject).to eql(bookings_subject)
            expect(b.placement_details).to eql(placement_details)
          end
        end
      end
    end

    context 'when the placement request belongs to a placement date' do
      let(:duration) { 3 }
      let(:pd) { create(:bookings_placement_date, duration: duration, bookings_school: @current_user_school) }
      let!(:pr) { create(:bookings_placement_request, school: @current_user_school, bookings_placement_date_id: pd.id) }

      before { subject }

      specify 'should set the booking from the placement date' do
        pr.booking.tap do |b|
          expect(b.duration).to eql(duration)
        end
      end
    end

    context 'with an invalid date' do
      let(:params) do
        {
          schools_placement_requests_confirm_booking: {
            bookings_subject_id: create(:bookings_subject).id,
            date: '2019-09-31',
            placement_details: "you'll get to try out teaching"
          }
        }
      end

      before { subject }

      specify 'should not create a new booking' do
        expect(pr.booking).to be_nil
      end

      specify 'should rerender the new template' do
        expect(response).to render_template(:new)
      end

      specify "should include an 'invalid date' error" do
        expect(response.body).to match(/Enter a valid date/)
      end
    end
  end
end
