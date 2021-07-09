require "rails_helper"

RSpec.describe Healthcheck do
  let(:gitsha) { "d64e925a5c70b05246e493de7b60af73e1dfa9dd" }
  shafile = "/etc/school-experience-sha"

  describe "#app_sha" do
    subject { described_class.new.app_sha }

    context "when #{shafile} is set" do
      before do
        allow(File).to receive(:read).with(shafile).and_return("#{gitsha}\n")
      end

      it { is_expected.to eql gitsha }
    end

    context "when #{shafile} is missing" do
      before do
        allow(File).to receive(:read).with(shafile).and_raise Errno::ENOENT
      end

      it { is_expected.to eql nil }
    end
  end

  describe "test_gitis" do
    include_context "fake gitis"

    subject { described_class.new.test_gitis }

    context "with working connection" do
      before do
        allow(fake_gitis).to receive(:fetch) { [Bookings::Gitis::Country.new] }
      end

      it { is_expected.to be true }
    end

    context "with broken connection" do
      before do
        allow(fake_gitis).to receive(:fetch).and_raise \
          Bookings::Gitis::API::BadResponseError.new \
            Struct.new(:status, :headers, :body, :env).new(500, {}, 'timeout')
      end

      it { is_expected.to be false }
    end

    context "when the git_api feature is enabled" do
      include_context "enable git_api feature"

      context "with a working connection" do
        before do
          response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "healthy", crm: "ok")
          allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
            receive(:health_check) { response }
        end

        it { is_expected.to be true }
      end

      context "with a broken connection" do
        before do
          allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
            receive(:health_check).and_raise(GetIntoTeachingApiClient::ApiError)
        end

        it { is_expected.to be false }
      end

      context "with a degraded connection (CRM offline)" do
        before do
          response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "degraded", crm: "ok")
          allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
            receive(:health_check) { response }
        end

        it { is_expected.to be true }
      end

      context "with a degraded connection (CRM offline)" do
        before do
          response = GetIntoTeachingApiClient::HealthCheckResponse.new(status: "degraded", crm: "offline")
          allow_any_instance_of(GetIntoTeachingApiClient::OperationsApi).to \
            receive(:health_check) { response }
        end

        it { is_expected.to be false }
      end
    end
  end

  describe "test_postgresql" do
    subject { described_class.new.test_postgresql }

    context "with working connection" do
      before do
        allow(ApplicationRecord).to receive(:connected?).and_return(true)
      end

      it { is_expected.to be true }
    end

    context "with broken connection" do
      before do
        allow(ApplicationRecord).to receive(:connected?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe "#test_redis" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("REDIS_URL").and_return \
        "redis://localhost:6379/1"
    end

    subject { described_class.new.test_redis }

    context "with working connection" do
      before do
        allow(Redis).to receive(:current).and_return double(Redis, ping: "PONG")
      end

      it { is_expected.to be true }
    end

    context "with broken connection" do
      it "returns false" do
        [Errno::ETIMEDOUT, Redis::CannotConnectError].each do |error|
          allow(Redis).to receive(:current).and_raise error
          expect(subject).to be false
        end
      end
    end

    context 'with non functional redis' do
      before do
        allow(Redis.current).to receive(:ping) { raise Redis::TimeoutError }
      end

      it { is_expected.to be false }
    end

    context "with no configured connection" do
      before do
        allow(ENV).to receive(:[]).with("REDIS_URL").and_return nil
      end

      it { is_expected.to be nil }
    end
  end

  describe "#test_dfe_signin_api" do
    before do
      allow(Schools::DFESignInAPI::Organisations).to receive(:enabled?).and_return(true)
    end

    subject { described_class.new.test_dfe_signin_api }

    context "with working connection" do
      before do
        allow_any_instance_of(Schools::DFESignInAPI::Organisations).to receive(:uuids).and_return({})
      end

      it { is_expected.to be true }
    end

    context "with non functional connection" do
      it "returns false" do
        [RuntimeError, Redis::CannotConnectError].each do |error|
          allow_any_instance_of(Schools::DFESignInAPI::Organisations).to receive(:response).and_raise error

          is_expected.to be false
        end
      end
    end

    context "with no configured connection" do
      before do
        allow(Schools::DFESignInAPI::Organisations).to receive(:enabled?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe "#to_h" do
    include_context "fake gitis"

    subject { described_class.new.to_h }
    it { is_expected.to include :deployment_id }
    it { is_expected.to include :app_sha }
    it { is_expected.to include :dfe_auth }
    it { is_expected.to include :gitis_api }
    it { is_expected.to include :db }
    it { is_expected.to include :cache }
    it { is_expected.to include :healthy }
    it { is_expected.to include :status }
  end

  describe "#to_json" do
    include_context "fake gitis"

    subject { JSON.parse described_class.new.to_json }
    it { is_expected.to include "deployment_id" }
    it { is_expected.to include "app_sha" }
    it { is_expected.to include "dfe_auth" }
    it { is_expected.to include "gitis_api" }
    it { is_expected.to include "db" }
    it { is_expected.to include "cache" }
    it { is_expected.to include "healthy" }
    it { is_expected.to include "status" }
  end
end
