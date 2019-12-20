require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequests::Cancellations::NotificationDeliveriesController, type: :request do
  include_context "logged in DfE user"

  let :school do
    Bookings::School.find_by!(urn: urn).tap do |s|
      s.subjects << FactoryBot.create_list(:bookings_subject, 5)
      FactoryBot.create(:bookings_profile, school: s)
    end
  end

  let :candidate_request_rejection_notification do
    double NotifyEmail::CandidateRequestRejection,
      despatch_later!: true
  end

  before do
    allow(NotifyEmail::CandidateRequestRejection).to receive(:new) do
      candidate_request_rejection_notification
    end
  end

  context '#create' do
    before do
      allow(Bookings::LogToGitisJob).to receive(:perform_later).and_return(true)

      post schools_placement_request_cancellation_notification_delivery_path \
        placement_request
    end

    context 'when request already closed' do
      let :placement_request do
        FactoryBot.create :placement_request, :cancelled, school: school
      end

      it 'redirects to the placement_show path' do
        expect(response).to redirect_to \
          schools_placement_requests_path(placement_request)
      end

      it 'does not enqueue a log to gitis job' do
        expect(Bookings::LogToGitisJob).not_to have_received(:perform_later)
      end
    end

    context 'when request not already closed' do
      include_context 'fake gitis'

      let :placement_request do
        FactoryBot.create \
          :placement_request, :with_school_cancellation, school: school
      end

      let :cancellation do
        placement_request.school_cancellation
      end

      let :gitis_contact do
        fake_gitis.find placement_request.contact_uuid
      end

      it 'notifies the candidate' do
        expect(NotifyEmail::CandidateRequestRejection).to have_received(:new).with \
          to: gitis_contact.email,
          school_name: cancellation.school_name,
          rejection_reasons: cancellation.rejection_description,
          extra_details: cancellation.extra_details,
          dates_requested: cancellation.dates_requested,
          school_search_url: new_candidates_school_search_url

        expect(candidate_request_rejection_notification).to \
          have_received :despatch_later!
      end

      it 'updates the placement_request to closed' do
        expect(placement_request.reload).to be_closed
      end

      it 'enqueues a log to gitis job' do
        expect(Bookings::LogToGitisJob).to \
          have_received(:perform_later).with \
            placement_request.contact_uuid, /CANCELLED BY SCHOOL/
      end

      it 'redirects to the show action' do
        expect(response).to redirect_to \
          schools_placement_request_cancellation_notification_delivery_path \
            placement_request
      end
    end
  end

  context '#show' do
    let :placement_request do
      FactoryBot.create \
        :placement_request, :cancelled_by_school, school: school
    end

    before do
      get schools_placement_request_cancellation_notification_delivery_path \
        placement_request
    end

    it 'assigns the cancellation' do
      expect(assigns(:cancellation)).to \
        eq placement_request.school_cancellation
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
