require 'rails_helper'

describe Bookings::Gitis::Factory do
  let(:factory) { described_class.new }

  describe '#token' do
    let(:auth) { Bookings::Gitis::Auth.new }
    before { allow(Bookings::Gitis::Auth).to receive(:new).and_return(auth) }
    before { expect(auth).to receive(:token).and_return('a.fake.token') }
    subject { factory.token }
    it { is_expected.to match %r{\A\w+\.\w+\.\w+\z} }
  end

  describe '#store' do
    before { allow(factory).to receive(:token).and_return('a.fake.token') }
    subject { factory.store }
    it { is_expected.to be_kind_of Bookings::Gitis::Store::Dynamics }
  end

  describe '#write_only_caching_store' do
    before { allow(factory).to receive(:token).and_return('a.fake.token') }
    subject! { factory.write_only_caching_store }
    it { is_expected.to be_kind_of Bookings::Gitis::Store::WriteOnlyCache }
    it { expect(factory).to have_received(:token) } # shows its chained through to dynamics
  end

  describe '#read_write_caching_store' do
    before { allow(factory).to receive(:token).and_return('a.fake.token') }
    subject! { factory.read_write_caching_store }
    it { is_expected.to be_kind_of Bookings::Gitis::Store::ReadWriteCache }
    it { expect(factory).to have_received(:token) } # shows its chained through to dynamics
  end

  describe '#caching_store' do
    before { allow(factory).to receive(:token).and_return('a.fake.token') }

    context 'with read_from_cache' do
      subject! { factory.caching_store(true) }
      it { is_expected.to be_kind_of Bookings::Gitis::Store::ReadWriteCache }
    end

    context 'without read_from_cache' do
      subject! { factory.caching_store(false) }
      it { is_expected.to be_kind_of Bookings::Gitis::Store::WriteOnlyCache }
    end
  end

  describe '#crm' do
    subject { factory.crm }

    context 'with fake_crm enabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(true)
      end

      it { is_expected.to be_kind_of Bookings::Gitis::FakeCrm }
      it { is_expected.to have_attributes store: kind_of(Bookings::Gitis::Store::WriteOnlyCache) }
      it { expect(subject.store).to have_attributes store: kind_of(Bookings::Gitis::Store::Fake) }
    end

    context 'with caching enabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(false)

        allow(Rails.application.config.x.gitis).to \
          receive(:caching).and_return(true)

        allow(factory).to receive(:token).and_return('a.fake.token')
      end

      it { is_expected.to be_kind_of Bookings::Gitis::CRM }
      it do
        is_expected.to have_attributes \
          store: kind_of(Bookings::Gitis::Store::WriteOnlyCache)
      end

      context 'with read_from_cache: true' do
        subject { factory.crm(read_from_cache: true) }
        it { is_expected.to be_kind_of Bookings::Gitis::CRM }
        it do
          is_expected.to have_attributes \
            store: kind_of(Bookings::Gitis::Store::ReadWriteCache)
        end
      end
    end

    context 'with fake_crm and caching disabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(false)

        allow(factory).to receive(:token).and_return('a.fake.token')
      end

      it { is_expected.to be_kind_of Bookings::Gitis::CRM }
      it { is_expected.to have_attributes store: kind_of(Bookings::Gitis::Store::Dynamics) }
    end
  end

  describe '#caching_crm' do
    before { allow(factory).to receive(:crm).and_return(nil) }
    subject! { factory.caching_crm }
    it { expect(factory).to have_received(:crm).with(read_from_cache: true) }
  end

  describe '.crm' do
    subject { described_class.crm }
    it { is_expected.to be_kind_of Bookings::Gitis::CRM }
  end

  describe '.caching_crm' do
    subject { described_class.caching_crm }
    it { is_expected.to be_kind_of Bookings::Gitis::CRM }
  end
end
