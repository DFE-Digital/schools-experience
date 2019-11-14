module Bookings
  module Gitis
    module Store
      class WriteOnlyCache
        attr_reader :store, :cache, :namespace, :ttl, :version
        delegate :fetch, to: :store

        def initialize(store, cache, namespace: nil, ttl: 1.hour, version: 'v1')
          @store = store
          @cache = cache
          @namespace = namespace
          @ttl = ttl
          @version = version
        end

        def cache_key_for_entity(entity)
          [namespace, entity.cache_key, version].compact.join('/')
        end

        def find(entity_type, uuids, **options)
          find_and_write_to_cache(entity_type, uuids, **options)
        end

        def write(entity)
          store.write(entity).tap do
            cache.delete cache_key_for_entity entity
          end
        end

      private

        def entities_to_cache(entities)
          Array.wrap(entities).each.with_object({}) do |entity, cache_set|
            cache_set[cache_key_for_entity(entity)] = entity.to_cache
          end
        end

        def find_and_write_to_cache(entity_type, uuids, **options)
          store.find(entity_type, uuids, **options).tap do |entities|
            if options.compact.empty?
              cache.write_multi entities_to_cache(entities), expires_in: ttl
            end
          end
        end
      end
    end
  end
end
