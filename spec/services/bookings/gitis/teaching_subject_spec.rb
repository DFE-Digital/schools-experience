require 'rails_helper'

RSpec.describe Bookings::Gitis::TeachingSubject, type: :model do
  let(:uuid) { SecureRandom.uuid }

  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('dfe_teachingsubjectlists') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('dfe_teachingsubjectlistid') }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :dfe_name }
    it { is_expected.to respond_to :dfe_teachingsubjectlistid }
  end

  describe '.new' do
    subject do
      described_class.new(
        'dfe_teachingsubjectlistid' => uuid,
        'dfe_name' => 'Test Subject'
      )
    end

    it { is_expected.to have_attributes(dfe_teachingsubjectlistid: uuid) }
    it { is_expected.to have_attributes(dfe_name: 'Test Subject') }
    it { is_expected.to have_attributes(changed_attributes: {}) }
  end
end
