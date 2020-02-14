require 'rails_helper'

describe ServiceUpdatesController, type: :request do
  let(:updates) { build_list :service_update, 3 }

  describe '#index' do
    before { allow(ServiceUpdate).to receive(:latest).with(6) { updates } }
    before { get service_updates_path }
    subject { response }

    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template 'index' }
    it { is_expected.to render_template '_service_update' }
  end
end
