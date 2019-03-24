require 'rails_helper'

describe "Expired Session", type: :request do
  context 'when InvalidAuthenticityToken is raised' do
    before do
      allow_any_instance_of(Candidates::HomeController).to receive(:index) do
        fail ActionController::InvalidAuthenticityToken
      end
    end

    it "will show the Expired Session page" do
      get candidates_root_path
      expect(response).to have_http_status(200)
      expect(response.body).to match(/Session expired/)
    end
  end
end