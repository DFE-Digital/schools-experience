module Bookings
  module Gitis
    module Store
      class ReadWriteCache < WriteOnlyCache
        def cache_key_for_uuid(entity_type, uuid)
          [namespace, entity_type.cache_key(uuid), version].compact.join('/')
        end

        def cache_keys_for_uuids(entity_type, uuids)
          uuids.map do |uuid|
            cache_key_for_uuid entity_type, uuid
          end
        end

        def find(entity_type, uuids, **options)
          return super if options.compact.any?

          if uuids.respond_to? :each
            find_many entity_type, uuids
          else
            find_one entity_type, uuids
          end
        end

      private

        def find_one(entity_type, uuid)
          match = read_from_cache(entity_type, [uuid])[0]
          match || find_and_write_to_cache(entity_type, uuid).freeze
        end

        def find_many(entity_type, uuids)
          from_cache = read_from_cache(entity_type, uuids)
          missing = uuids - from_cache.map(&:id)
          from_cache + read_from_store(entity_type, missing)
        end

        def read_from_cache(entity_type, uuids)
          keys = cache_keys_for_uuids(entity_type, uuids)
          cache.read_multi(*keys).values \
            .map(&entity_type.method(:from_cache))
        end

        def read_from_store(entity_type, uuids)
          return [] if uuids.empty?

          find_and_write_to_cache(entity_type, uuids).map(&:freeze)
        end
      end
    end
  end
end
