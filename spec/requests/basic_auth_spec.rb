require "rails_helper"

describe "Basic authentication", type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("REDIS_URL") { "redis://localhost:6379/1" }

    allow(REDIS).to receive(:ping) { "PONG" }
    allow(ApplicationRecord).to receive(:connected?) { true }

    allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
      receive(:health_check) { GetIntoTeachingApiClient::HealthCheckResponse.new(status: "healthy") }

    allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
      receive_messages(enabled?: true, uuids: [])
  end

  context "when the environment requires basic auth" do
    before do
      allow(ENV).to receive(:[]).with("SECURE_USERNAME") { "user" }
      allow(ENV).to receive(:[]).with("SECURE_PASSWORD") { "pass" }
      allow(Rails).to receive(:env) { "staging".inquiry }
    end

    it "authenticates on the root path" do
      get root_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "responds with success when given the correct credentials" do
      auth_header = ActionController::HttpAuthentication::Basic.encode_credentials("user", "pass")
      get root_path, headers: { "HTTP_AUTHORIZATION" => auth_header }
      expect(response).to have_http_status(:success)
    end

    it "authenticates on the /healthcheck.json path" do
      get healthcheck_json_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "authenticates on the /healthcheck.txt path" do
      get healthcheck_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "does not authenticate on the /deployment.txt path" do
      get deployment_path
      expect(response).to have_http_status(:success)
    end

    it "does not authenticate on the /deployment.json path" do
      get deployment_json_path
      expect(response).to have_http_status(:success)
    end

    it "does not authenticate on the /healthchecks/api.txt path" do
      get api_health_path
      expect(response).to have_http_status(:success)
    end

    it "does not authenticate on the /whitelist path" do
      get urn_whitelist_path
      expect(response).to have_http_status(:success)
    end
  end

  context "when the environment does not require basic auth" do
    it "does not authenticate on the root path" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "does not authenticate on the /healthcheck.json path" do
      get healthcheck_json_path
      expect(response).to have_http_status(:success)
    end

    it "does not authenticate on the /healthcheck.txt path" do
      get healthcheck_path
      expect(response).to have_http_status(:success)
    end
  end
end
