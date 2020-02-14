require 'rails_helper'

describe ServiceUpdatesController, type: :request do
  let(:updates) { build_list :service_update, 3 }

  describe '#index' do
    before { allow(ServiceUpdate).to receive(:latest).with(6) { updates } }
    before { get service_updates_path }
    subject { response }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template 'index' }
    it { is_expected.to render_template '_service_update' }
  end

  describe '#show' do
    before do
      allow(ServiceUpdate).to \
        receive(:from_param).with(updates[0].to_param) { updates[0] }

      get service_update_path updates[0]
    end
    subject { response }

    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template 'show' }
  end
end
