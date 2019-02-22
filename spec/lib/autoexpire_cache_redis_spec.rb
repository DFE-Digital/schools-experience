require 'rails_helper'
require Rails.root.join('lib', 'autoexpire_cache_redis')

describe AutoexpireCacheRedis do
  let(:redis) { Redis.current }
  subject { described_class.new(redis) }

  let(:key) { "some_key" }
  let(:value) { "some_value" }

  before { subject[key] = value }

  it 'should correctly set the value' do
    expect(subject[key]).to eql(value)
  end

  it 'should set the ttl of new records to a month in the future' do
    expect(redis.ttl(key)).to be_within(2).of(1.month)
  end

  context 'when the expiry is overridden' do
    subject { described_class.new(redis, 2.months) }

    it 'should set the ttl of new records to a month in the future' do
      expect(redis.ttl(key)).to be_within(2).of(2.month)
    end
  end
end
