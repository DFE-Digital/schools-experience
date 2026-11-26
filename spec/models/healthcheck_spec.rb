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

      it { is_expected.to be_nil }
    end
  end

  describe "test_gitis" do
    subject { described_class.new.test_gitis }

    context "with a working connection" do
      include_context "when the API is healthy"

      it { is_expected.to be true }
    end

    context "with a broken connection" do
      include_context "when the API cannot be reached"

      it { is_expected.to be false }
    end

    context "with a degraded connection (CRM online)" do
      include_context "when the API is degraded but CRM is online"

      it { is_expected.to be true }
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
    subject { described_class.new.test_redis }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("REDIS_URL").and_return \
        "redis://localhost:6379/1"
    end

    context "with working connection" do
      before do
        allow(REDIS).to receive(:ping).and_return("PONG")
      end

      it { is_expected.to be true }
    end

    context "with broken connection" do
      it "returns false" do
        [Errno::ETIMEDOUT, Redis::CannotConnectError, OpenSSL::SSL::SSLError, IOError].each do |error|
          allow(REDIS).to receive(:ping).and_raise error
          expect(subject).to be false
        end
      end
    end

    context 'with non functional redis' do
      before do
        allow(REDIS).to receive(:ping) { raise Redis::TimeoutError }
      end

      it { is_expected.to be false }
    end

    context "with no configured connection" do
      before do
        allow(ENV).to receive(:[]).with("REDIS_URL").and_return nil
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#test_dfe_signin_api" do
    subject { described_class.new.test_dfe_signin_api }

    let(:dfe_healthcheck) do
      instance_double(Schools::DFESignInAPI::Healthcheck, up?: true)
    end

    before do
      allow(Schools::DFESignInAPI::Healthcheck).to receive(:new).and_return(dfe_healthcheck)
    end

    context "when the DfE Sign In healthcheck reports up" do
      it { is_expected.to be true }
    end

    context "when the DfE Sign In healthcheck reports down" do
      let(:dfe_healthcheck) do
        instance_double(Schools::DFESignInAPI::Healthcheck, up?: false)
      end

      it { is_expected.to be false }
    end

    context "when the DfE Sign In healthcheck raises an unexpected StandardError" do
      before do
        allow(dfe_healthcheck).to receive(:up?).and_raise(TypeError, "no implicit conversion of nil into String")
      end

      it { is_expected.to be false }
    end

    context "when the request times out (Rack::Timeout::RequestTimeoutException)" do
      before do
        allow(dfe_healthcheck).to receive(:up?).and_raise(Rack::Timeout::RequestTimeoutException.new({}))
      end

      it { is_expected.to be false }
    end
  end

  describe "#to_h" do
    subject { described_class.new.to_h }

    include_context "when the API is healthy"

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
    subject { JSON.parse described_class.new.to_json }

    include_context "when the API is healthy"

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
