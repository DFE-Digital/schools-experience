require 'rails_helper'

RSpec.describe Candidates::DashboardsController, type: :request do
  describe "GET #show" do
    it_behaves_like "candidate signed out", -> { get candidates_dashboard_path }

    context "when signed in" do
      include_context 'candidate signin'

      let(:school) { build :bookings_school }
      let(:other_school) { build :bookings_school }
      let(:placement_requests) { create_list :placement_request, 1, school: school }
      let(:current_candidate_placement_requests) do
        create_list :placement_request, 2, candidate: current_candidate, school: school
      end

      before do
        # Ensure there are placement requests for other candidates
        create_list :placement_request, 2, school: other_school
        get candidates_dashboard_path
      end

      it 'assigns the current contact' do
        expect(assigns(:current_candidate)).to eq(current_candidate)
      end

      it "assigns the placement requests of the current candidate" do
        expect(assigns(:placement_requests)).to match_array(current_candidate_placement_requests)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
