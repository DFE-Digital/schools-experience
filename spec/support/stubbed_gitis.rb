require 'apimock/gitis_crm'

shared_context "stubbed out Gitis" do
  let(:tenant_id) { SecureRandom.uuid }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'secret' }
  let(:service_url) { 'https://my-service.com' }

  let(:gitis_stubs) do
    Apimock::GitisCrm.new(client_id, client_secret, tenant_id, service_url)
  end

  let(:gitis) do
    Bookings::Gitis::CRM.new('a.stub.token', service_url: service_url)
  end

  let(:gitis_auth) do
    Bookings::Gitis::Auth.new(
      client_id: client_id,
      client_secret: client_secret,
      tenant_id: tenant_id,
      service_url: service_url
    )
  end

  before do
    allow(Bookings::Gitis::Auth).to receive(:new).and_return(gitis_auth)
    allow(gitis_auth).to receive(:token).and_return('a.stub.token')
    allow(Bookings::Gitis::CRM).to receive(:new).and_return(gitis)
    gitis_stubs.stub_contact_request(1)
  end
end
