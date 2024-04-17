require 'rails_helper'

RSpec.describe Candidates::DashboardsController, type: :request do
  describe "GET #show" do
    it "redirects to /candidates" do
      get candidates_dashboard_path
      expect(response).to redirect_to("/candidates")
    end
  end
end
