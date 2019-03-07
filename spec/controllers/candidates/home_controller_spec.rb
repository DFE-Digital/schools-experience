require 'rails_helper'

RSpec.describe Candidates::HomeController, type: :request do
  describe "GET #index" do
    it "returns http success with the Candidate landing page" do
      get candidates_root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #splash" do
    it "returns http success with the Candidate landing page" do
      get candidates_splash_path
      expect(response).to have_http_status(:success)
    end
  end
end
