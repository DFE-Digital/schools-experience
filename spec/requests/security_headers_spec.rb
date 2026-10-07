require 'rails_helper'

describe "Security headers", type: :request do
  before { get "/candidates" }

  it "returns a successful response" do
    expect(response).to have_http_status(:success)
  end

  it "sets a cross-origin opener policy of same-origin" do
    expect(response.headers["Cross-Origin-Opener-Policy"]).to eq("same-origin")
  end

  it "sets a cross-origin resource policy of same-origin" do
    expect(response.headers["Cross-Origin-Resource-Policy"]).to eq("same-origin")
  end

  it "sets a permissions policy locking down sensitive features" do
    policy = response.headers["Permissions-Policy"]

    expect(policy).to be_present
    expect(policy).to include("camera=()")
    expect(policy).to include("microphone=()")
    expect(policy).to include("geolocation=()")
    expect(policy).to include("payment=()")
    expect(policy).to include("fullscreen=(self)")
  end

  describe "content security policy" do
    subject(:csp) { response.headers["Content-Security-Policy"] }

    it "explicitly defines form-action so it does not fall back to default-src" do
      expect(csp).to include("form-action 'self'")
    end

    it "explicitly defines frame-ancestors so it does not fall back to default-src" do
      expect(csp).to include("frame-ancestors 'self'")
    end
  end
end
