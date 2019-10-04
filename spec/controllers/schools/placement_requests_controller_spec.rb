require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequestsController, type: :request do
  include_context "logged in DfE user"

  let :school do
    Bookings::School.find_by! urn: urn
  end

  let! :profile do
    create(:bookings_profile, school: school)
  end

  before do
    school.subjects << FactoryBot.create_list(:bookings_subject, 5)
  end

  context '#index' do
    let(:placement_requests) do
      FactoryBot.create_list :placement_request, 5, school: school
    end

    before do
      get '/schools/placement_requests'
    end

    it 'assigns the placement_requests belonging to the school' do
      expect(assigns(:placement_requests)).to eq school.placement_requests
      expect(assigns(:placement_requests).map(&:gitis_contact)).to all \
        be_kind_of Bookings::Gitis::Contact
    end

    it 'renders the index template' do
      expect(response).to render_template :index
    end

    context 'after placement requests have been accepted' do
      let(:booked) { placement_requests.last }
      before do
        create(:bookings_booking, :accepted, bookings_placement_request: booked, bookings_school: school)
      end

      before { get '/schools/placement_requests' }

      specify 'they should be omitted' do
        expect(assigns(:placement_requests).sort_by(&:id)).to \
          eq((school.placement_requests - Array.wrap(booked)).sort_by(&:id))
      end
    end
  end

  context '#show' do
    before do
      get "/schools/placement_requests/#{placement_request.id}"
    end

    context 'with a new placement request' do
      let :placement_request do
        FactoryBot.create :placement_request, school: school
      end

      it 'assigns the correct placement_request' do
        expect(assigns(:placement_request)).to eq placement_request
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end

    context 'with a placement request cancelled by candidate' do
      let :placement_request do
        create :placement_request, :cancelled, school: school
      end

      it 'marks the cancellation as viewed' do
        expect(placement_request.reload.candidate_cancellation).to be_viewed
      end
    end
  end
end
