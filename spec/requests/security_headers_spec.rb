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

    def directive(csp, name)
      csp.split(";").map(&:strip).find { |d| d.start_with?("#{name} ") }
    end

    it "does not allow inline styles globally" do
      expect(directive(csp, "style-src")).not_to include("'unsafe-inline'")
    end

    it "does not retain the obsolete Flipper UI sources" do
      expect(csp).not_to include("code.jquery.com")
      expect(csp).not_to include("cdnjs.cloudflare.com")
      expect(csp).not_to include("maxcdn.bootstrapcdn.com")
    end

    it "keeps the Google Maps and tag manager sources needed for style and script loading" do
      expect(directive(csp, "style-src")).to include("https://fonts.googleapis.com")
      expect(directive(csp, "script-src")).to include("https://maps.googleapis.com")
    end

    it "keeps script-src free of unsafe-eval and unsafe-inline" do
      expect(directive(csp, "script-src")).not_to include("'unsafe-eval'", "'unsafe-inline'")
    end

    it "emits a style nonce in the header that matches a style element in the body" do
      nonce = directive(csp, "style-src")[/'nonce-([^']+)'/, 1]

      expect(nonce).to be_present
      expect(response.body).to include(%(<style nonce="#{nonce}"></style>))
    end

    it "uses a fresh style nonce for each response" do
      first = directive(csp, "style-src")[/'nonce-([^']+)'/, 1]
      get "/candidates"
      second = directive(response.headers["Content-Security-Policy"], "style-src")[/'nonce-([^']+)'/, 1]

      expect(first).not_to eq(second)
    end
  end
end
