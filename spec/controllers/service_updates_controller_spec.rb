require 'rails_helper'

describe ServiceUpdatesController, type: :request do
  let(:updates) { build_list :service_update, 3 }

  describe '#show' do
    before { allow(ServiceUpdate).to receive(:latest).with(10) { updates } }
    before { get service_update_path }
    subject { response }

    it { is_expected.to have_http_status(:success) }
    it { is_expected.to render_template 'show' }
    it { is_expected.to render_template '_service_update' }
  end
end
