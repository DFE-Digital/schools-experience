require 'rails_helper'

describe PagesController, type: :request do
  describe '#privacy_policy' do
    context 'with known policy' do
      before do
        allow(Bookings::Gitis::PrivacyPolicy).to \
          receive(:default).and_return('d1adf2ad-e7c4-e911-a981-000d3a206976')

        get privacy_policy_path
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template 'privacy_policy' }
      it { expect(response).to render_template '_d1adf2ad-e7c4-e911-a981-000d3a206976' }
    end

    context 'with unknown policy' do
      before do
        allow(Bookings::Gitis::PrivacyPolicy).to \
          receive(:default).and_return(SecureRandom.uuid)
      end

      it "will raise an exception" do
        expect {
          get privacy_policy_path
        }.to raise_exception(ActionView::Template::Error)
      end
    end
  end

  describe 'maintenance mode' do
    before do
      allow(Rails.application.config.x).to receive(:maintenance_mode) { true }
      Rails.application.reload_routes!
    end

    after do
      allow(Rails.application.config.x).to receive(:maintenance_mode).and_call_original
      Rails.application.reload_routes!
    end

    it "will show the maintenance page" do
      get root_path
      expect(response).to have_http_status(:service_unavailable)
      expect(response).to have_attributes body: /service is unavailable/i

      get candidates_root_path
      expect(response).to have_http_status(:service_unavailable)
      expect(response).to have_attributes body: /service is unavailable/i
    end
  end
end
