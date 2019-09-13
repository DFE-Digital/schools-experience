require 'rails_helper'

describe HealthchecksController, type: :request do
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
      let(:username) { Rails.application.config.x.healthchecks.username }
      let(:password) { Rails.application.config.x.healthchecks.password }
      let(:encoded) do
        ActionController::HttpAuthentication::Basic.
          encode_credentials(username, password)
      end

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
end
