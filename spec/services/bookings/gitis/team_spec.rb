require 'rails_helper'

RSpec.describe Bookings::Gitis::Team, type: :model do
  let(:uuid) { SecureRandom.uuid }

  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('teams') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('ownerid') }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :ownerid }
  end

  describe '.new' do
    subject do
      described_class.new(
        'ownerid' => uuid,
        'name' => 'Test Team'
      )
    end

    it { is_expected.to have_attributes(ownerid: uuid) }
    it { is_expected.to have_attributes(name: 'Test Team') }
    it { is_expected.to have_attributes(changed_attributes: {}) }
  end

  describe '.default' do
    before do
      allow(Rails.application.config.x.gitis).to \
        receive(:owner_id).and_return(uuid)
    end

    subject { described_class.default }
    it { is_expected.to eql(uuid) }
  end
end
