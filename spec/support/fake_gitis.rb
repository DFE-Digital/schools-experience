shared_context "fake gitis" do
  let(:fake_gitis) { Bookings::Gitis::FakeCrm.new }
  before { allow(Bookings::Gitis::FakeCrm).to receive(:new).and_return(fake_gitis) }
end

shared_context "fake gitis with known uuid" do
  include_context 'fake gitis'

  let(:fake_gitis_uuid) { SecureRandom.uuid }

  before do
    allow(fake_gitis.store).to receive(:fake_contact_id).and_return(fake_gitis_uuid)
  end
end
