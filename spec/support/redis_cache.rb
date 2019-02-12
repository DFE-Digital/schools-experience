RSpec.shared_context 'redis_cache' do
  if metadata[:redis_cache]
    let :cache_store do
      ActiveSupport::Cache.lookup_store :redis_cache_store, namespace: 'TEST'
    end

    before do
      cache_store.clear

      allow(Rails).to receive(:cache) { cache_store }
    end

    after do
      cache_store.clear
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'redis_cache'
end
