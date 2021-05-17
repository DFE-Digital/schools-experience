require "rails_helper"

describe "Flipper UI", type: :request do
  let(:password) { nil }
  let(:headers) do
    {
      "HTTP_AUTHORIZATION" =>
      ActionController::HttpAuthentication::Basic.encode_credentials(
        nil,
        password
      )
    }
  end

  before { allow(Rails).to receive(:env) { env.inquiry } }

  subject do
    get "/flipper", headers: headers
    response
  end

  context "when development" do
    let(:env) { "development" }

    it { is_expected.to have_http_status(:found) }
  end

  context "when in production" do
    let(:env) { "production" }

    it { is_expected.to have_http_status(:unauthorized) }

    context "when credentials are correct" do
      let(:password) { "password" }

      before do
        allow(Rails.application.config.x).to receive(:flipper_password) { password }
      end

      it { is_expected.to have_http_status(:found) }
    end
  end
end
