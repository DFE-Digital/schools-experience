require 'rails_helper'

RSpec.describe Bookings::Gitis::Auth do
  let(:tenant_id) { SecureRandom.uuid }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'secret' }
  let(:service_url) { 'https://my-service.com' }

  describe '.new' do
    subject do
      described_class.new(
        client_id: client_id,
        client_secret: client_secret,
        tenant_id: tenant_id,
        service_url: service_url
      )
    end

    it "will return a valid instance" do
      is_expected.to be_kind_of Bookings::Gitis::Auth
    end
  end

  describe "#token" do
    let(:api) do
      Apimock::GitisCrm.new(client_id, client_secret, tenant_id, service_url)
    end

    context "with valid credentials" do
      before { api.stub_access_token }

      subject do
        described_class.new(
          client_id: client_id,
          client_secret: client_secret,
          tenant_id: tenant_id,
          service_url: service_url
        )
      end

      it "returns a token" do
        expect(subject.token).to match(/\w+\.\w+\.\w+/)
      end

      it "sets the expires" do
        subject.token
        expect(subject.expires_at).to be_kind_of(Time)
        expect(subject.expires_at).to be_within(10.seconds).of(1.hour.from_now)
      end
    end

    context "with invalid credentials" do
      before { api.stub_invalid_access_token }

      subject do
        described_class.new(
          client_id: client_id,
          client_secret: 'invalid',
          tenant_id: tenant_id,
          service_url: service_url
        )
      end

      it "will raise an exception" do
        expect { subject.token }.to \
          raise_exception Bookings::Gitis::Auth::UnableToRetrieveToken
      end
    end
  end
end
