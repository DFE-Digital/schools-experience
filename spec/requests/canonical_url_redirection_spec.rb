require 'rails_helper'

describe "Redirecting to Canonical Domain", type: :request do
  shared_examples "perform healthchecks" do
    before do
      healthcheck = instance_double(
        Healthcheck,
        test_gitis: true,
        test_redis: true,
        test_postgresql: true,
        test_dfe_signin_api: true,
        deployment: 'not set',
        to_h: { healthy: true },
        to_json: '{"healthy":true}'
      )
      allow(Healthcheck).to receive(:new).and_return(healthcheck)
    end

    specify "will allow direct access to /healthcheck" do
      get healthcheck_path

      expect(response).to have_http_status(:success)
      expect(response.body).to match('healthy')
    end

    specify "will allow direct access to /deployment" do
      get deployment_path

      expect(response).to have_http_status(:success)
      expect(response.body).to match('not set')
    end

    specify "will allow direct access to all /healthcheck/api.txt paths" do
      get api_health_path

      expect(response).to have_http_status(:success)
      expect(response.body).to match('healthy')
    end
  end

  around do |example|
    original_canonical_domain = ENV['CANONICAL_DOMAIN']
    ENV['CANONICAL_DOMAIN'] = "canonical-domain"
    example.run
  ensure
    ENV['CANONICAL_DOMAIN'] = original_canonical_domain
  end

  context "with request to canonical-domain" do
    before { host! "canonical-domain" }

    specify "will return a 200" do
      get "/candidates?foo=bar"

      expect(response).to have_http_status(:success)
    end

    include_examples 'perform healthchecks'
  end

  context "with request to alternative-domain" do
    before { host! "alternative-domain" }

    specify "will return a redirect" do
      get "/candidates?foo=bar"

      expect(response).to have_http_status(302)
      expect(response).to redirect_to("http://canonical-domain/candidates?foo=bar")
    end

    include_examples 'perform healthchecks'
  end
end
