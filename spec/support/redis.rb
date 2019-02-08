RSpec.shared_context 'redis' do
  let :test_namespace do
    'TEST'
  end

  let :cache_store do
    ActiveSupport::Cache.lookup_store \
      :redis_cache_store,
      namespace: test_namespace
  end

  before do
    cache_store.clear

    allow(Rails).to receive(:cache) { cache_store }
  end

  after do
    cache_store.clear
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'redis'
end
