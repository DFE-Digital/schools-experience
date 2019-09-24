require 'rails_helper'

describe Candidates::PlacementRequests::CancellationsController, type: :request do
  include_context 'fake gitis'

  let :notify_school_request_cancellation do
    double NotifyEmail::SchoolRequestCancellation, despatch_later!: true
  end

  let :notify_candidate_request_cancellation do
    double NotifyEmail::CandidateRequestCancellation, despatch_later!: true
  end

  let :notify_school_booking_cancellation do
    double NotifyEmail::SchoolBookingCancellation, despatch_later!: true
  end

  let :notify_candidate_booking_cancellation do
    double NotifyEmail::CandidateBookingCancellation, despatch_later!: true
  end

  before do
    allow(NotifyEmail::SchoolRequestCancellation).to receive :new do
      notify_school_request_cancellation
    end

    allow(NotifyEmail::CandidateRequestCancellation).to receive :new do
      notify_candidate_request_cancellation
    end

    allow(NotifyEmail::SchoolBookingCancellation).to receive :new do
      notify_school_booking_cancellation
    end

    allow(NotifyEmail::CandidateBookingCancellation).to receive :new do
      notify_candidate_booking_cancellation
    end
  end

  context '#new' do
    before do
      get "/candidates/placement_requests/#{placement_request.token}/cancellation/new"
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          candidates_placement_request_cancellation_path(placement_request.token)
      end
    end

    context 'when request not already closed' do
      context 'when does not have a booking' do
        let :placement_request do
          FactoryBot.create :placement_request
        end

        it 'renders the new template' do
          expect(response).to render_template :new
        end
      end

      context 'when has a booking' do
        let :placement_request do
          FactoryBot.create :placement_request, :booked
        end

        it 'renders the new template' do
          expect(response).to render_template :new
        end
      end
    end
  end

  context '#create' do
    let :cancellation_params do
      { bookings_placement_request_cancellation: cancellation.attributes }
    end

    before do
      allow(Bookings::LogToGitisJob).to receive(:perform_later).and_return(true)

      post \
        "/candidates/placement_requests/#{placement_request.token}/cancellation/",
        params: cancellation_params
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled
      end

      let :cancellation do
        FactoryBot.build :cancellation, \
          reason: 'Some other reason',
          placement_request: nil
      end

      it 'doesnt create the placement request' do
        expect(placement_request.candidate_cancellation.reason).not_to \
          eq cancellation.reason
      end

      it 'does not notify the school' do
        expect(notify_school_request_cancellation).not_to \
          have_received :despatch_later!
      end

      it 'does not notify the candidate' do
        expect(notify_candidate_request_cancellation).not_to \
          have_received :despatch_later!
      end

      it 'does not enqueues a log to gitis job' do
        expect(Bookings::LogToGitisJob).not_to \
          have_received(:perform_later)
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          candidates_placement_request_cancellation_path(placement_request.token)
      end
    end

    context 'when request not already closed' do
      context 'when request does not have a booking' do
        let :placement_request do
          FactoryBot.create :placement_request
        end

        context 'invalid' do
          let :cancellation do
            Bookings::PlacementRequest::Cancellation.new
          end

          it 'does not notify the school' do
            expect(notify_school_request_cancellation).not_to \
              have_received :despatch_later!
          end

          it 'does not notify the candidate' do
            expect(notify_candidate_request_cancellation).not_to \
              have_received :despatch_later!
          end

          it 'does not cancel the placement request' do
            expect(placement_request).not_to be_closed
          end

          it 'does not enqueues a log to gitis job' do
            expect(Bookings::LogToGitisJob).not_to \
              have_received(:perform_later)
          end

          it 'rerenders the new template' do
            expect(response).to render_template :new
          end
        end

        context 'valid' do
          let :cancellation do
            FactoryBot.build :cancellation, placement_request: placement_request
          end

          let :gitis_contact do
            fake_gitis.find placement_request.contact_uuid
          end

          it 'notifies the school' do
            expect(NotifyEmail::SchoolRequestCancellation).to have_received(:new).with \
              to: cancellation.school_email,
              school_name: cancellation.school_name,
              candidate_name: gitis_contact.full_name,
              cancellation_reasons: cancellation.reason,
              requested_on: cancellation.placement_request.requested_on.to_formatted_s(:govuk),
              placement_request_url: schools_placement_request_url(cancellation.placement_request)

            expect(notify_school_request_cancellation).to \
              have_received :despatch_later!
          end

          it 'notifies the candidate' do
            expect(NotifyEmail::CandidateRequestCancellation).to have_received(:new).with \
              to: gitis_contact.email,
              school_name: cancellation.school_name,
              requested_availability: cancellation.dates_requested,
              school_search_url: new_candidates_school_search_url

            expect(notify_candidate_request_cancellation).to \
              have_received :despatch_later!
          end

          it 'creates the cancellation' do
            expect(placement_request.candidate_cancellation.reason).to \
              eq cancellation.reason
          end

          it 'cancels the placement request' do
            expect(placement_request).to be_closed
          end

          it 'enqueues a log to gitis job' do
            expect(Bookings::LogToGitisJob).to \
              have_received(:perform_later).with \
                placement_request.contact_uuid, /CANCELLED BY CANDIDATE/
          end

          it 'redirects to the show action' do
            expect(response).to redirect_to \
              candidates_placement_request_cancellation_path(placement_request.token)
          end
        end
      end

      context 'when the request has a booking' do
        let :placement_request do
          FactoryBot.create :placement_request, :booked
        end

        context 'invalid' do
          let :cancellation do
            Bookings::PlacementRequest::Cancellation.new
          end

          it 'does not notify the school' do
            expect(notify_school_booking_cancellation).not_to \
              have_received :despatch_later!
          end

          it 'does not notify the candidate' do
            expect(notify_candidate_booking_cancellation).not_to \
              have_received :despatch_later!
          end

          it 'does not cancel the placement request' do
            expect(placement_request).not_to be_closed
          end

          it 'rerenders the new template' do
            expect(response).to render_template :new
          end
        end

        context 'valid' do
          let :cancellation do
            FactoryBot.build :cancellation, placement_request: placement_request
          end

          let :gitis_contact do
            fake_gitis.find placement_request.contact_uuid
          end

          it 'notifies the school' do
            expect(NotifyEmail::SchoolBookingCancellation).to have_received(:new).with \
              to: cancellation.school_email,
              school_name: cancellation.school_name,
              candidate_name: gitis_contact.full_name,
              placement_start_date_with_duration: cancellation.booking.placement_start_date_with_duration

            expect(notify_school_booking_cancellation).to \
              have_received :despatch_later!
          end

          it 'notifies the candidate' do
            expect(NotifyEmail::CandidateBookingCancellation).to have_received(:new).with \
              to: gitis_contact.email,
              school_name: cancellation.school_name,
              placement_start_date_with_duration: cancellation.booking.placement_start_date_with_duration,
              school_search_url: new_candidates_school_search_url

            expect(notify_candidate_booking_cancellation).to \
              have_received :despatch_later!
          end

          it 'creates the cancellation' do
            expect(placement_request.candidate_cancellation.reason).to \
              eq cancellation.reason
          end

          it 'cancels the placement request' do
            expect(placement_request).to be_closed
          end

          it 'redirects to the show action' do
            expect(response).to redirect_to \
              candidates_placement_request_cancellation_path(placement_request.token)
          end
        end
      end
    end
  end

  context '#show' do
    let :placement_request do
      FactoryBot.create :placement_request, :cancelled
    end

    before do
      get \
        "/candidates/placement_requests/#{placement_request.token}/cancellation"
    end

    context 'when does not have a booking' do
      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end

    context 'when has a booking' do
      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
