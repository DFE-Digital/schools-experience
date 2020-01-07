describe GitisAccess do
  let(:factory) { Bookings::Gitis::Factory }
  before { allow(factory).to receive(:crm) { true } }

  context 'without configuring caching' do
    class ModuleTester
      include GitisAccess
    end

    subject! { ModuleTester.new.gitis_crm }
    it { expect(factory).to have_received(:crm).with(read_from_cache: false) }
  end

  context 'without configuring caching' do
    class CachedModuleTester
      include GitisAccess
      self.use_gitis_cache = true
    end

    subject! { CachedModuleTester.new.gitis_crm }
    it { expect(factory).to have_received(:crm).with(read_from_cache: true) }
  end
end
