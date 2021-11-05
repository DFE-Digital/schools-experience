require 'rails_helper'

RSpec.describe Candidates::HomeController, type: :request do
  describe "GET #index" do
    before do
      get candidates_root_path
    end

    it "returns http success with the Candidate landing page" do
      expect(response).to have_http_status(:success)
    end

    it 'includes a meta description tag' do
      expect(response.body).to include('<meta name="description" content="The Department for Education')
    end
  end
end
