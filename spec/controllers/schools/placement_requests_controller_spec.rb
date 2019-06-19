require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::PlacementRequestsController, type: :request do
  include_context "logged in DfE user"
  include_context "stubbed out Gitis"

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
    before do
      FactoryBot.create_list :placement_request, 5, school: school
      get '/schools/placement_requests'
    end

    it 'assigns the placement_requests belonging to the school' do
      expect(assigns(:placement_requests)).to eq school.placement_requests
    end

    it 'renders the index template' do
      expect(response).to render_template :index
    end
  end

  context '#show' do
    let :placement_request do
      FactoryBot.create :placement_request, school: school
    end

    before do
      get "/schools/placement_requests/#{placement_request.id}"
    end

    it 'assigns the correct placement_request' do
      expect(assigns(:placement_request)).to eq placement_request
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
