require 'rails_helper'

RSpec.describe Candidates::DashboardsController, type: :request do
  describe "GET #show" do
    before { get candidates_dashboard_path }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end
