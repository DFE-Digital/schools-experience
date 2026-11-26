require 'rails_helper'

describe "Expired Session", type: :request do
  context 'when InvalidAuthenticityToken is raised' do
    subject(:perform_request) do
      get candidates_root_path
      response
    end

    before do
      allow(Candidates::HomeController).to receive(:new).and_wrap_original do |original, *args|
        original.call(*args).tap do |controller|
          allow(controller).to receive(:index) do
            raise ActionController::InvalidAuthenticityToken
          end
        end
      end
    end


    it { is_expected.to have_http_status(:success) }
    it { expect(perform_request.body).to include("Session expired") }

    it "increments the invalid_authenticity_token metric" do
      expect { perform_request }.to increment_yabeda_counter(Yabeda.gse.invalid_authenticity_token).by(1)
    end
  end
end
