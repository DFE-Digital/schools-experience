require 'rails_helper'

describe "Expired Session", type: :request do
  context 'when InvalidAuthenticityToken is raised' do
    before do
      allow_any_instance_of(Candidates::HomeController).to receive(:index) do
        raise ActionController::InvalidAuthenticityToken
      end
    end

    subject(:perform_request) do
      get candidates_root_path
      response
    end

    it { is_expected.to have_http_status(:success) }
    it { expect(perform_request.body).to include("Session expired") }

    it "increments the invalid_authenticity_token metric" do
      expect { perform_request }.to increment_yabeda_counter(Yabeda.gse.invalid_authenticity_token).by(1)
    end
  end
end
