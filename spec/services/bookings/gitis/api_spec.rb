require 'rails_helper'

describe Bookings::Gitis::API do
  let(:token) { "My.Stub.Token" }
  let(:service_url) { "https://my.service.com" }
  let(:endpoint) { '/api/v1.0' }
  let(:uuid) { '86b2839b-a009-48a7-89b6-294d2ed37bd2' }

  describe ".initialize" do
    subject do
      described_class.new(token, service_url: service_url, endpoint: endpoint)
    end

    it "will initialize" do
      is_expected.to be_kind_of(Bookings::Gitis::API)
    end

    it "will set the completed endpoint_url" do
      expect(subject.endpoint_url).to eq('https://my.service.com/api/v1.0')
    end
  end

  describe ".get" do
    let(:api) do
      described_class.new(token, service_url: service_url, endpoint: endpoint)
    end

    context "for valid url" do
      before do
        stub_request(:get, "#{service_url}#{endpoint}/contacts?$top=1").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 200,
            headers: {
              'content-type' => 'application/json; odata.metadata=minimal',
              'odata-version' => '4.0'
            },
            body: {
              'contactid' => uuid,
              'firstname' => 'test',
              'lastname' => 'test'
            }.to_json
          )
      end

      subject { api.get('contacts', '$top' => 1) }

      it { is_expected.to be_kind_of Hash }
      it { is_expected.to include('contactid' => uuid) }
      it { is_expected.to include('firstname' => 'test', 'lastname' => 'test') }
    end

    context 'for inaccessible url' do
      before do
        stub_request(:get, "#{service_url}#{endpoint}/contacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 401,
            headers: {
              'odata-version' => '4.0'
            },
            body: 'Access Denied'
          )
      end

      it "will raise an AccessDeniedError" do
        expect {
          api.get('contacts')
        }.to raise_exception(Bookings::Gitis::API::BadResponseError, /401: Access Denied/i)
      end
    end

    context "for invalid url" do
      before do
        stub_request(:get, "#{service_url}#{endpoint}/contacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 500,
            headers: {
              'odata-version' => '4.0'
            },
            body: 'Something went wrong'
          )
      end

      it "will raise an BadResponseError" do
        expect {
          api.get('contacts')
        }.to raise_exception(Bookings::Gitis::API::BadResponseError, /500: Something went wrong/i)
      end
    end

    context 'for absolute url' do
      subject { api.get('/contacts') }

      it "should raise exception" do
        expect {
          api.get('/contacts')
        }.to raise_exception Bookings::Gitis::API::UnsupportedAbsoluteUrlError
      end
    end

    context 'for unknown url' do
      before do
        stub_request(:get, "#{service_url}#{endpoint}/ontacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 404,
            headers: {
              'content-type' => 'application/json; odata.metadata=minimal',
              'odata-version' => '4.0'
            },
            body: {
              "error" => {
                "code" => "0x8006088a",
                "message" => "Resource not found for the segment 'ontacts'"
              }
            }.to_json
          )
      end

      it "will raise an UnknownUrlError" do
        expect {
          api.get('ontacts')
        }.to raise_exception(Bookings::Gitis::API::UnknownUrlError, /404: resource not found/i)
      end
    end
  end

  describe ".post" do
    let(:api) do
      described_class.new(token, service_url: service_url, endpoint: endpoint)
    end

    context "for valid url" do
      before do
        stub_request(:post, "#{service_url}#{endpoint}/contacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            'Content-Type' => 'application/json',
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 204,
            headers: {
              'odata-version' => '4.0',
              'odata-entityid' => "#{service_url}#{endpoint}/contacts(#{uuid})"
            },
            body: ''
          )
      end

      subject { api.post('contacts', 'firstname' => 'test', 'lastname' => 'user') }

      it { is_expected.to eq("#{service_url}#{endpoint}/contacts(#{uuid})") }
    end

    context "for invalid url" do
      before do
        stub_request(:post, "#{service_url}#{endpoint}/contacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            'Content-Type' => 'application/json',
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 500,
            headers: { 'odata-version' => '4.0' },
            body: ''
          )
      end

      it "will raise an BadResponseError" do
        expect {
          api.post('contacts', 'firstname' => 'test', 'lastname' => 'user')
        }.to raise_exception(Bookings::Gitis::API::BadResponseError, /500:/i)
      end
    end

    context 'for absolute url' do
      subject { api.get('/contacts') }

      it "should raise exception" do
        expect {
          api.post('/contacts', 'firstname' => 'test', 'lastname' => 'user')
        }.to raise_exception Bookings::Gitis::API::UnsupportedAbsoluteUrlError
      end
    end

    context 'for unknown url' do
      before do
        stub_request(:post, "#{service_url}#{endpoint}/ontacts").
          with(headers: {
            'Accept' => 'application/json',
            'Authorization' => /\ABearer #{token}/,
            'Content-Type' => 'application/json',
            "OData-MaxVersion" => "4.0",
            "OData-Version" => "4.0",
          }).
          to_return(
            status: 404,
            headers: {
              'content-type' => 'application/json; odata.metadata=minimal',
              'odata-version' => '4.0'
            },
            body: {
              "error" => {
                "code" => "0x8006088a",
                "message" => "Resource not found for the segment 'ontacts'"
              }
            }.to_json
          )
      end

      it "will raise an UnknownUrlError" do
        expect {
          api.post('ontacts', 'firstname' => 'test', 'lastname' => 'user')
        }.to raise_exception(Bookings::Gitis::API::UnknownUrlError, /404: resource not found/i)
      end
    end
  end
end
