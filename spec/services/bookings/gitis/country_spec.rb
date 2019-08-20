require 'rails_helper'

RSpec.describe Bookings::Gitis::Country, type: :model do
  let(:uuid) { SecureRandom.uuid }

  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('dfe_countries') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('dfe_countryid') }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :dfe_name }
    it { is_expected.to respond_to :dfe_countryid }
  end

  describe '.new' do
    subject do
      described_class.new(
        'dfe_countryid' => uuid,
        'dfe_name' => 'Test Country'
      )
    end

    it { is_expected.to have_attributes(dfe_countryid: uuid) }
    it { is_expected.to have_attributes(dfe_name: 'Test Country') }
    it { is_expected.to have_attributes(changed_attributes: {}) }
  end
end
