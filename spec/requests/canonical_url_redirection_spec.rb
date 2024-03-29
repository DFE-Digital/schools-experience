require 'rails_helper'

describe "Redirecting to Canonical Domain", type: :request do
  shared_examples "perform healthchecks" do
    before do
      allow_any_instance_of(Healthcheck).to \
        receive(:test_gitis).and_return(true)
      allow_any_instance_of(Healthcheck).to \
        receive(:test_redis).and_return(true)
      allow_any_instance_of(Healthcheck).to \
        receive(:test_postgresql).and_return(true)
      allow_any_instance_of(Healthcheck).to \
        receive(:test_dfe_signin_api).and_return(true)
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

  before do
    @orig_canonical_domain = ENV['CANONICAL_DOMAIN']
    ENV['CANONICAL_DOMAIN'] = "canonical-domain"
  end

  after do
    ENV['CANONICAL_DOMAIN'] = @orig_canonical_domain
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
