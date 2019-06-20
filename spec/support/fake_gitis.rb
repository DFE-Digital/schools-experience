shared_context "fake gitis" do
  let(:fake_gitis) do
    unless Bookings::Gitis::CRM < Bookings::Gitis::FakeCrm
      raise "Not running with FakeCrm"
    end

    Bookings::Gitis::CRM.new('a.fake.token')
  end
end
