require 'rails_helper'

describe Bookings::Gitis::Factory do
  let(:factory) { described_class.new }

  describe '#token' do
    subject { factory.token }
    it { is_expected.to match %r{\A\w+\.\w+\.\w+\z} }
  end

  describe '#store' do
    subject { factory.store }

    context 'with fake_crm enabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(true)
      end

      it { is_expected.to be_kind_of Bookings::Gitis::Store::Fake }
    end

    context 'with fake_crm disabled' do
      before do
        allow(Rails.application.config.x.gitis).to \
          receive(:fake_crm).and_return(false)

        allow(factory).to receive(:token).and_return('a.fake.token')
      end

      it { is_expected.to be_kind_of Bookings::Gitis::Store::Dynamics }
    end
  end

  describe '#crm' do
    subject { factory.crm }
    it { is_expected.to be_kind_of Bookings::Gitis::CRM }
  end

  describe '.crm' do
    subject { described_class.crm }
    it { is_expected.to be_kind_of Bookings::Gitis::CRM }
  end
end
