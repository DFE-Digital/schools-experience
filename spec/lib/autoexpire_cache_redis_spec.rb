require 'rails_helper'
require Rails.root.join('lib', 'autoexpire_cache_redis')

describe AutoexpireCacheRedis do
  let(:store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  subject { described_class.new(store) }

  let(:key) { "some_key" }
  let(:value) { "some_value" }

  it 'should correctly set the value' do
    subject[key] = value
    expect(subject[key]).to eql(value)
  end

  context 'expiry defaults to 1 month' do
    before do
      allow(subject.store).to receive(:write).and_return(true)
    end

    before { subject[key] = value }

    it 'should set the ttl of new records to a month in the future' do
      expect(subject.store).to have_received(:write).with(key, value, expires_in: 1.month)
    end
  end

  context 'overriding the expiry' do
    subject { described_class.new(store, 2.months) }

    it 'should set the ttl of new records to be the newly-specified value' do
      expect(subject.ttl).to be_within(1).of(2.month)
    end
  end
end
