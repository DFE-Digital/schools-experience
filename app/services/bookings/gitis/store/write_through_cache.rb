module Bookings
  module Gitis
    module Store
      class WriteThroughCache
        VERSION = 'v1'.freeze

        attr_reader :store, :cache
        delegate :find, :fetch, to: :store

        def initialize(store, cache)
          @store = store
          @cache = cache
        end

        def cache_key_for_entity(entity)
          "#{entity.cache_key}/#{VERSION}"
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
