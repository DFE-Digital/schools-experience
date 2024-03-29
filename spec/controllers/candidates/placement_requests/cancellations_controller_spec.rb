require 'rails_helper'

describe Candidates::PlacementRequests::CancellationsController, type: :request do
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

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
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

    allow(Bookings::Gitis::SchoolExperience).to \
      receive(:from_cancellation) { school_experience }

    allow(school_experience).to \
      receive(:write_to_gitis_contact)
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

      it 'does not send a school experience to the API' do
        expect(school_experience).not_to \
          have_received(:write_to_gitis_contact)
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

          it 'does not send a school experience to the API' do
            expect(school_experience).not_to \
              have_received(:write_to_gitis_contact)
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
            api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
            api.get_schools_experience_sign_up(placement_request.contact_uuid)
          end

          it 'notifies the school' do
            full_name = "#{gitis_contact.first_name} #{gitis_contact.last_name}"

            expect(NotifyEmail::SchoolRequestCancellation).to have_received(:new).with \
              to: cancellation.school_email,
              school_name: cancellation.school_name,
              candidate_name: full_name,
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

          it 'creates a withdrawn school experience and sends it to the API' do
            expect(Bookings::Gitis::SchoolExperience).to \
              have_received(:from_cancellation).with(instance_of(Bookings::PlacementRequest::Cancellation), :withdrawn)

            expect(school_experience).to \
              have_received(:write_to_gitis_contact).with(placement_request.contact_uuid)
          end

          context "when the request has been accepted by the school (it has a booking)" do
            let :placement_request do
              FactoryBot.create :placement_request, :booked
            end

            it 'creates a cancelled by candidate school experience and sends it to the API' do
              expect(Bookings::Gitis::SchoolExperience).to \
                have_received(:from_cancellation).with(instance_of(Bookings::PlacementRequest::Cancellation), :cancelled_by_candidate)

              expect(school_experience).to \
                have_received(:write_to_gitis_contact).with(placement_request.contact_uuid)
            end
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
            api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
            api.get_schools_experience_sign_up(placement_request.contact_uuid)
          end

          it 'notifies the school' do
            full_name = "#{gitis_contact.first_name} #{gitis_contact.last_name}"

            expect(NotifyEmail::SchoolBookingCancellation).to have_received(:new).with \
              to: cancellation.school_email,
              school_name: cancellation.school_name,
              candidate_name: full_name,
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
    before do
      get \
        "/candidates/placement_requests/#{placement_request.token}/cancellation"
    end

    context 'when cancelled by the candidate' do
      let :placement_request do
        create :placement_request, :cancelled
      end

      context 'when does not have a booking' do
        it 'renders the show template' do
          expect(response).to render_template :show
        end
      end

      context 'when has a booking' do
        let :placement_request do
          create :placement_request, :cancelled, :booked
        end

        it 'renders the show template' do
          expect(response).to render_template :show
        end
      end
    end

    context 'when cancelled by the school' do
      let :placement_request do
        create :placement_request, :cancelled_by_school
      end

      context 'when does not have a booking' do
        it 'renders the show template' do
          expect(response).to render_template :show
        end
      end

      context 'when has a booking' do
        let :placement_request do
          create :placement_request, :cancelled_by_school, :booked
        end

        it 'renders the show template' do
          expect(response).to render_template :show
        end
      end
    end
  end
end
