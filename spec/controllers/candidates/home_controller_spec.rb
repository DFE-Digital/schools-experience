require 'rails_helper'

RSpec.describe Candidates::HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success with the Candidate landing page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
