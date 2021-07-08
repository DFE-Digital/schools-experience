require 'rails_helper'

describe HealthchecksController, type: :request do
  let(:username) { Rails.application.config.x.healthchecks.username }
  let(:password) { Rails.application.config.x.healthchecks.password }
  let(:encoded) do
    ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  include_context "fake gitis"

  before do
    allow(ENV).to receive(:[]).and_call_original

    allow(fake_gitis).to \
      receive(:fetch) { [Bookings::Gitis::Country.new] }

    allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
      receive(:enabled?).and_return(true)

    allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
      receive(:uuids).and_return([])

    allow(ENV).to receive(:[]).with("REDIS_URL").and_return \
      "redis://localhost:6379/1"
    allow(Redis).to \
      receive(:current).and_return double(Redis, ping: "PONG")

    allow(ApplicationRecord).to \
      receive(:connected?).and_return(true)
  end

  describe '#show' do
    context 'with functional dependencies' do
      before { get healthcheck_path }

      it { expect(response.body).to include_json(cache: true) }
      it { expect(response.body).to include_json(db: true) }
      it { expect(response.body).to include_json(dfe_auth: true) }
      it { expect(response.body).to include_json(gitis_api: true) }
      it { expect(response).to have_http_status(:success) }
    end

    context 'with unhealthy Cache' do
      before do
        allow(Redis.current).to receive(:ping) { raise Redis::TimeoutError }

        get healthcheck_path
      end

      it { expect(response.body).to include_json(cache: false) }
      it { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy Database' do
      before do
        allow(ApplicationRecord).to receive(:connected?).and_return(false)

        get healthcheck_path
      end

      it { expect(response.body).to include_json(db: false) }
      it { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy Auth Service' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Client).to \
          receive(:response).and_raise Faraday::TimeoutError

        get healthcheck_path
      end

      xit { expect(response.body).to include_json(auth: false) }
      xit { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy API' do
      before do
        allow(fake_gitis).to receive(:fetch).and_raise \
          Bookings::Gitis::API::BadResponseError.new \
            Struct.new(:status, :headers, :body, :env).new(500, {}, 'timeout')

        get healthcheck_path
      end

      it { expect(response.body).to include_json(gitis_api: false) }
      it { expect(response).to have_http_status(:error) }
    end

    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"

      context "with unhealthy API" do
        before do
          allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
            receive(:health_check).and_raise(GetIntoTeachingApiClient::ApiError)

          get healthcheck_path
        end

        it { expect(response.body).to include_json(gitis_api: false) }
        it { expect(response).to have_http_status(:error) }
      end
    end
  end

  describe '#deployment' do
    context "with DEPLOYMENT_ID set" do
      before do
        allow(ENV).to receive(:fetch).with('DEPLOYMENT_ID').and_return('1997-08-29')

        get deployment_path
      end

      it { expect(response).to have_attributes body: '1997-08-29' }
    end

    context 'without DEPLOYMENT_ID set' do
      before { get deployment_path }

      it { expect(response).to have_attributes body: 'not set' }
    end
  end

  describe '#urn_whitelist' do
    let(:whitelist) { '123456,456123,654321' }

    context 'with no URN whitelist set' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('CANDIDATE_URN_WHITELIST').and_return('')

        get urn_whitelist_path
      end

      it { expect(response).to have_attributes body: '[]' }
    end

    context 'with a URN whitelist set' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('CANDIDATE_URN_WHITELIST').and_return(whitelist)

        get urn_whitelist_path
      end

      it { expect(response).to have_attributes body: "[#{whitelist}]" }
    end
  end

  describe '#api_health' do
    context 'with healthy dependencies' do
      before { get api_health_path }

      it { expect(response).to have_attributes body: 'healthy' }
      it { expect(response).to have_http_status(:success) }
    end

    context 'with no Auth Service' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
          receive(:enabled?).and_return(false)

        get api_health_path
      end

      it { expect(response).to have_attributes body: 'healthy' }
      it { expect(response).to have_http_status(:success) }
    end

    context 'with unhealthy API' do
      before do
        allow(fake_gitis).to receive(:fetch).and_raise \
          Bookings::Gitis::API::BadResponseError.new \
            Struct.new(:status, :headers, :body, :env).new(500, {}, 'timeout')

        get api_health_path
      end

      it { expect(response).to have_attributes body: 'unhealthy' }
      it { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy Auth Service' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to \
          receive(:uuids).and_raise Faraday::TimeoutError

        get api_health_path
      end

      xit { expect(response).to have_attributes body: 'unhealthy' }
      xit { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy Auth Service' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Client).to \
          receive(:response).and_raise Faraday::TimeoutError

        get api_health_path
      end

      xit { expect(response).to have_attributes body: 'unhealthy' }
      xit { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy Cache' do
      before do
        allow(Redis.current).to receive(:ping) { raise Redis::TimeoutError }

        get api_health_path
      end

      it { expect(response).to have_attributes body: 'unhealthy' }
      it { expect(response).to have_http_status(:error) }
    end

    context 'with unhealthy DB' do
      before do
        allow(ApplicationRecord).to receive(:connected?).and_return(false)

        get api_health_path
      end

      it { expect(response).to have_attributes body: 'unhealthy' }
      it { expect(response).to have_http_status(:error) }
    end
  end
end
