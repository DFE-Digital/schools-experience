require 'rails_helper'
require 'apimock/gitis_crm'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::ConfirmedBookings::DateController, type: :request do
  include_context "logged in DfE user"

  let(:booking) do
    create(:bookings_booking, :accepted, bookings_school: @current_user_school)
  end

  let!(:profile) { create(:bookings_profile, school: @current_user_school) }

  describe '#edit' do
    subject { get edit_schools_booking_date_path(booking.id) }

    specify do
      expect(subject).to render_template(:edit)
    end

    context 'with cancelled booking' do
      before do
        booking.bookings_placement_request.create_candidate_cancellation! \
          attributes_for(:cancellation, :cancelled_by_candidate, :sent)
      end

      specify do
        is_expected.to render_template(:uneditable)
      end
    end
  end

  describe '#update' do
    let(:new_date) { 3.weeks.from_now.to_date }
    let(:params) do
      { bookings_booking: { date: new_date.to_formatted_s(:govuk) } }
    end

    let(:old_date) { booking.date }

    subject { patch schools_booking_date_path(booking.id, params: params) }

    specify 'should redirect to the booking page' do
      expect(subject).to redirect_to(schools_booking_date_path(booking))
    end

    context 'updating the booking' do
      before { subject }

      specify 'should update the booking' do
        expect(booking.reload.date).to eql(new_date)
      end
    end

    context 'with cancelled booking' do
      before do
        booking.bookings_placement_request.create_candidate_cancellation! \
          attributes_for(:cancellation, :cancelled_by_candidate, :sent)

        subject
      end

      specify do
        is_expected.to render_template(:uneditable)
      end
    end

    context 'events' do
      before do
        allow(Event).to receive(:create).and_return(true)
      end

      before { subject }

      specify 'should add an event' do
        expect(Event).to have_received(:create).with(
          event_type: :booking_date_changed,
          bookings_school: @current_user_school,
          recordable: booking
        )
      end
    end

    context 'sending an email' do
      include_context 'fake gitis'

      let :email do
        double(NotifyEmail::CandidateBookingDateChanged, despatch_later!: true)
      end

      before do
        allow(NotifyEmail::CandidateBookingDateChanged).to receive(:from_booking).and_return(email)
      end

      before do
        booking
          .bookings_placement_request
          .fetch_gitis_contact(fake_gitis)
      end

      before { subject }

      specify 'should send a candidate booking date changed email with the correct values' do
        expect(NotifyEmail::CandidateBookingDateChanged).to have_received(:from_booking).with(
          booking.candidate_email,
          booking.candidate_name,
          booking,
          candidates_cancel_url(booking.token),
          old_date.strftime("%d %B %Y")
        )
      end
    end

    context 'updating with same date' do
      let(:date) { booking.date }
      let(:params) do
        { bookings_booking: { date: date.to_formatted_s(:govuk) } }
      end

      subject! { patch schools_booking_date_path(booking.id, params: params) }

      specify("should render edit page") do
        expect(response).to have_http_status 200
        expect(response).to have_attributes body: /change the booking date/i
      end
    end
  end

  describe '#show' do
    subject { get schools_booking_date_path(booking.id) }

    specify do
      expect(subject).to render_template(:show)
    end

    context 'dynamic contents' do
      before { subject }

      specify 'should contain the new date' do
        expect(response.body).to match(booking.date.to_formatted_s(:govuk))
      end
    end
  end
end
