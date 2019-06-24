require 'rails_helper'

RSpec.describe Candidates::DashboardsController, type: :request do
  describe "GET #show" do
    it_behaves_like "candidate signed out", -> { get candidates_dashboard_path }

    context "when signed in" do
      include_context 'candidate signin'
      before { get candidates_dashboard_path }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
