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

  describe '#crm' do
    subject { factory.crm }

    context 'with fake_crm enabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(true)
      end

      it { is_expected.to be_kind_of Bookings::Gitis::FakeCrm }
      it { is_expected.to have_attributes store: kind_of(Bookings::Gitis::Store::Fake) }
    end

    context 'with fake_crm disabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(false)

        allow(factory).to receive(:token).and_return('a.fake.token')
      end

      it { is_expected.to be_kind_of Bookings::Gitis::CRM }
      it { is_expected.to have_attributes store: kind_of(Bookings::Gitis::Store::Dynamics) }
    end
  end

  describe '.crm' do
    subject { described_class.crm }
    it { is_expected.to be_kind_of Bookings::Gitis::CRM }
  end
end
