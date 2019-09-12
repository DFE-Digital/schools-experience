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
end
