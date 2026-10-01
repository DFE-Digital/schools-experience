require 'rails_helper'

describe Schools::DFESignInAPI::Healthcheck do
  let(:help_host) { Rails.configuration.x.dfe_sign_in_help_host }
  let(:url) { "https://#{help_host}/healthcheck" }

  subject { described_class.new.up? }

  before do
    allow(Rails.application.config.x).to \
      receive(:dfe_sign_in_api_enabled).and_return(true)
  end

  context 'when DfE Sign In is enabled' do
    context 'and the endpoint reports status up' do
      before do
        stub_request(:get, url).to_return(
          status: 200,
          body: {
            status: 'up',
            details: [{ key: 'connectionString', path: 'notifications.connectionString', status: 'ok' }]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it { is_expected.to be true }

      it 'requests the help host healthcheck with no Authorization header' do
        subject

        expect(
          a_request(:get, url).with { |req| req.headers['Authorization'].nil? }
        ).to have_been_made
      end
    end

    context 'and the endpoint reports a non-up status' do
      before do
        stub_request(:get, url).to_return(status: 200, body: { status: 'down' }.to_json)
      end

      it { is_expected.to be false }
    end

    context 'and the response body has no status' do
      before do
        stub_request(:get, url).to_return(status: 200, body: {}.to_json)
      end

      it { is_expected.to be false }
    end

    context 'and the response body is not valid JSON' do
      before do
        stub_request(:get, url).to_return(status: 200, body: '<html>maintenance</html>')
      end

      it { is_expected.to be false }
    end

    context 'and the endpoint returns 404' do
      before { stub_request(:get, url).to_return(status: 404) }

      it { is_expected.to be false }
    end

    context 'and the endpoint returns 503' do
      before { stub_request(:get, url).to_return(status: 503) }

      it { is_expected.to be false }
    end

    context 'and the connection times out' do
      before { stub_request(:get, url).to_timeout }

      it { is_expected.to be false }
    end
  end

  context 'when DfE Sign In is disabled' do
    before do
      allow(Rails.application.config.x).to \
        receive(:dfe_sign_in_api_enabled).and_return(false)
    end

    it 'reports healthy - there is nothing to probe' do
      is_expected.to be true
    end

    it 'makes no outbound request' do
      stub = stub_request(:get, url)

      subject

      expect(stub).not_to have_been_requested
    end
  end
end
