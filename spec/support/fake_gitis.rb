shared_context "fake gitis" do
  let(:fake_gitis) do
    unless Bookings::Gitis::CRM < Bookings::Gitis::FakeCrm
      raise "Not running with FakeCrm"
    end

    Bookings::Gitis::CRM.new('a.fake.token')
  end

  before { allow(Bookings::Gitis::CRM).to receive(:new).and_return(fake_gitis) }
end

shared_context "fake gitis with known uuid" do
  include_context 'fake gitis'

  let(:fake_gitis_uuid) { SecureRandom.uuid }

  before do
    allow(fake_gitis.fake_backend).to receive(:fake_contact_id).and_return(fake_gitis_uuid)
  end
end
