require 'rails_helper'

describe HealthchecksController, type: :request do
  let(:username) { Rails.application.config.x.healthchecks.username }
  let(:password) { Rails.application.config.x.healthchecks.password }
  let(:encoded) do
    ActionController::HttpAuthentication::Basic.
      encode_credentials(username, password)
  end

  describe '#show' do
    context 'with functional redis and postgres' do
      before { get healthcheck_path }
      it { expect(response).to have_http_status(:success) }
    end

    context 'with non functional redis' do
      before do
        allow(Redis.current).to receive(:ping) { fail Redis::TimeoutError }
      end

      it "will raise an exception" do
        expect { get healthcheck_path }.to raise_exception(Redis::TimeoutError)
      end
    end

    context 'with non functional postgres' do
      before do
        allow(ApplicationRecord).to receive(:connected?).and_return(false)
      end

      it "will raise an exception" do
        expect { get healthcheck_path }.to raise_exception(RuntimeError)
      end
    end
  end

  describe '#deployment' do
    context "with auth" do
      context "with DEPLOYMENT_ID set" do
        before do
          allow(ENV).to \
            receive(:fetch).with('DEPLOYMENT_ID').and_return('1997-08-29')

          get deployment_path, headers: { "Authorization" => encoded }
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_attributes body: '1997-08-29' }
      end

      context 'without DEPLOYMENT_ID set' do
        before do
          get deployment_path, headers: { "Authorization" => encoded }
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_attributes body: 'not set' }
      end
    end

    context 'without auth' do
      before { get deployment_path }
      it { expect(response).to have_http_status(:unauthorized) }
    end
  end

  describe '#api_health' do
    include_context "fake gitis"
    let(:check_api_health) { get api_health_path, headers: { "Authorization" => encoded } }

    before do
      allow(fake_gitis).to receive(:fetch) { [Bookings::Gitis::Country.new] }
      allow_any_instance_of(Schools::DFESignInAPI::Client).to \
        receive(:response).and_return([])
      allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
    end

    context 'with all APIs healthy' do
      before { check_api_health }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_attributes body: 'healthy' }
    end

    context 'with unhealthy Gitis' do
      before do
        allow(fake_gitis).to receive(:fetch).and_raise \
          Bookings::Gitis::API::BadResponseError.new \
            Struct.new(:status, :headers, :body, :env).new(500, {}, 'timeout')
      end

      it "will raise an error" do
        expect { check_api_health }.to \
          raise_exception Bookings::Gitis::API::BadResponseError
      end
    end

    context 'with unhealthy DfE Sign In' do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Client).to \
          receive(:response).and_raise Faraday::TimeoutError
      end

      it "will raise an error" do
        expect { check_api_health }.to raise_exception Faraday::Error
      end
    end
  end
end
