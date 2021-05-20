if Rails.env.test?
  require 'active_support/cache'
  require 'flipper/adapters/active_support_cache_store'

  Flipper.configure do |config|
    config.adapter do
      Flipper::Adapters::ActiveSupportCacheStore.new(
        Flipper::Adapters::Memory.new,
        ActiveSupport::Cache::MemoryStore.new,
      )
    end
  end
else
  require 'flipper/adapters/redis'
end

Rails.application.configure do
  config.flipper.memoize = false
end

Flipper::UI.configure do |config|
  config.fun = false
end
