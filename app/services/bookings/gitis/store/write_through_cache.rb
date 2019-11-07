module Bookings
  module Gitis
    module Store
      class WriteThroughCache
        VERSION = 'v1'.freeze

        attr_reader :store, :cache, :namespace
        delegate :find, :fetch, to: :store

        def initialize(store, cache, namespace: nil)
          @store = store
          @cache = cache
          @namespace = namespace
        end

        def cache_key_for_entity(entity)
          [namespace, entity.cache_key, VERSION].compact.join('/')
        end

        def write(entity)
          store.write(entity).tap do
            cache.delete cache_key_for_entity entity
          end
        end
      end
    end
  end
end
