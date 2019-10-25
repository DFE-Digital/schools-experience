shared_context "fake gitis" do
  let(:fake_gitis_store) { Bookings::Gitis::Store::Fake.new }
  let(:fake_gitis) { Bookings::Gitis::CRM.new fake_gitis_store }

  before { allow(Bookings::Gitis::CRM).to receive(:new).and_return(fake_gitis) }
end

shared_context "fake gitis with known uuid" do
  include_context 'fake gitis'

  let(:fake_gitis_uuid) { SecureRandom.uuid }

  before do
    allow(fake_gitis_store).to receive(:fake_contact_id).and_return(fake_gitis_uuid)
  end
end
