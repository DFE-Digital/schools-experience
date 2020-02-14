require 'rails_helper'

describe ServiceUpdatesController, type: :request do
  let(:updates) { build_list :service_update, 3 }
  let(:service_update_cookie) { cookies[ServiceUpdate.cookie_key] }

  describe '#index' do
    before { allow(ServiceUpdate).to receive(:latest).with(6) { updates.dup } }
    before { get service_updates_path }
    subject { response }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template 'index' }
    it { is_expected.to render_template '_service_update' }
    it { expect(service_update_cookie).to eq updates[0].to_param }
  end

  describe '#show' do
    before do
      allow(ServiceUpdate).to \
        receive(:from_param).with(update.to_param) { update }

      get service_update_path update
    end
    subject! { response }

    context 'for latest update' do
      let(:update) { updates[0].dup }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'show' }
      it { expect(service_update_cookie).to eq update.to_param }
    end

    context 'for older update' do
      let(:update) { updates[2].dup }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'show' }
      it { expect(service_update_cookie).to eq updates[2].to_param }
    end
  end
end
