require 'rails_helper'

RSpec.describe Candidate::HomeController, type: :request do
  describe "GET #index" do
    it "returns http success with the Candidate landing page" do
      get candidate_root_path
      expect(response).to have_http_status(:success)
    end
  end
end
