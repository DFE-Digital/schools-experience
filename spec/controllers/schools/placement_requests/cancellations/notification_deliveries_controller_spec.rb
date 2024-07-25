require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequests::Cancellations::NotificationDeliveriesController, type: :request do
  include_context "logged in DfE user"
  include_context "Degree subject autocomplete enabled"

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

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end

  before do
    allow(NotifyEmail::CandidateRequestRejection).to receive(:new) do
      candidate_request_rejection_notification
    end

    allow(Bookings::Gitis::SchoolExperience).to \
      receive(:from_cancellation) { school_experience }

    allow(school_experience).to \
      receive(:write_to_gitis_contact)
  end

  context '#create' do
    before do
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

      it 'does not send a school experience to the API' do
        expect(school_experience).not_to \
          have_received(:write_to_gitis_contact)
      end
    end

    context 'when request not already closed' do
      let :placement_request do
        FactoryBot.create \
          :placement_request, :with_school_cancellation, school: school
      end

      let :cancellation do
        placement_request.school_cancellation
      end

      let :gitis_contact do
        api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
        api.get_schools_experience_sign_up(placement_request.contact_uuid)
      end

      it 'notifies the candidate' do
        expect(NotifyEmail::CandidateRequestRejection).to have_received(:new).with \
          to: gitis_contact.email,
          school_name: cancellation.school_name,
          rejection_reasons: cancellation.humanised_rejection_categories,
          extra_details: cancellation.extra_details,
          dates_requested: cancellation.dates_requested,
          school_search_url: new_candidates_school_search_url,
          candidate_name: gitis_contact.full_name
        expect(candidate_request_rejection_notification).to \
          have_received :despatch_later!
      end

      it 'updates the placement_request to closed' do
        expect(placement_request.reload).to be_closed
      end

      it 'creates a school experience and sends it to the API' do
        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_cancellation).with(instance_of(Bookings::PlacementRequest::Cancellation), :rejected)

        expect(school_experience).to \
          have_received(:write_to_gitis_contact).with(placement_request.contact_uuid)
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
