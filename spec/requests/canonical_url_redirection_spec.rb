require 'rails_helper'

describe "Redirecting to Canonical Domain", type: :request do
  shared_examples "perform healthchecks" do
    let(:username) { Rails.application.config.x.healthchecks.username }
    let(:password) { Rails.application.config.x.healthchecks.password }
    let(:encoded) do
      ActionController::HttpAuthentication::Basic.
        encode_credentials(username, password)
    end

    before do
      allow_any_instance_of(HealthchecksController).to \
        receive(:check_gitis_api).and_return(true)
    end

    specify "will allow direct access to healthcheck.txt" do
      get healthcheck_path

      expect(response).to have_http_status(200)
      expect(response.body).to match('healthy')
    end

    specify "will allow direct access to deployment.txt" do
      get deployment_path, headers: { "Authorization" => encoded }

      expect(response).to have_http_status(200)
      expect(response.body).to match('not set')
    end

    specify "will allow direct access to all healthcheck paths" do
      get api_health_path, headers: { "Authorization" => encoded }

      expect(response).to have_http_status(200)
      expect(response.body).to match('healthy')
    end
  end

  before do
    @orig_canonical_domain = ENV['CANONICAL_DOMAIN']
    @orig_sep_domain = ENV['OLD_SEP_DOMAIN']
    ENV['CANONICAL_DOMAIN'] = "canonical-domain"
  end

  after do
    ENV['CANONICAL_DOMAIN'] = @orig_canonical_domain
    ENV['OLD_SEP_DOMAINS'] = @orig_sep_domain
  end

  context "with request to canonical-domain" do
    before { host! "canonical-domain" }

    specify "will return a 200" do
      get "/candidates?foo=bar"

      expect(response).to have_http_status(200)
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

  context "with request to migrate domain" do
    context 'when there is one migrate domain' do
      before do
        ENV['OLD_SEP_DOMAINS'] = "migrate-domain-one"
      end
      before { host! "migrate-domain-one" }

      specify "will redirect to migration page" do
        get "/candidates?foo=bar"

        expect(response).to have_http_status(302)
        expect(response).to redirect_to("http://canonical-domain/pages/migration")
      end
    end

    context 'when there are two migrate domains' do
      before do
        ENV['OLD_SEP_DOMAINS'] = "migrate-domain-one,migrate-domain-two"
      end

      context 'first migrate domain' do
        before { host! "migrate-domain-one" }

        specify "will redirect to migration page" do
          get "/candidates?foo=bar"

          expect(response).to have_http_status(302)
          expect(response).to redirect_to("http://canonical-domain/pages/migration")
        end
      end

      context 'first migrate domain' do
        before { host! "migrate-domain-two" }

        specify "will redirect to migration page" do
          get "/candidates?foo=bar"

          expect(response).to have_http_status(302)
          expect(response).to redirect_to("http://canonical-domain/pages/migration")
        end
      end
    end
  end
end
