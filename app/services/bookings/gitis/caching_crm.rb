module Bookings::Gitis
  module CachingCrm
    EXPIRATION = 1.hour.freeze

    def find(uuids, entity_type: Contact, refresh: false, **options)
      return super unless cache_enabled?

      multiple_ids = uuids.is_a?(Array)

      uuids = normalise_ids(uuids)
      validate_ids(uuids)

      remove_from_cache(entity_type, uuids) if refresh

      if multiple_ids
        cached_find_many(entity_type, uuids)
      else
        cached_find_one(entity_type, uuids[0])
      end
    end

    def write(entity)
      super.tap do |entity_id|
        if cache_enabled?
          Rails.cache.delete cache_key(entity.class, entity_id)
        end
      end
    end

  private

    def cached_find_one(type, uuid)
      Rails.cache.fetch(cache_key(type, uuid), expires_in: EXPIRATION) do
        crmlog "READING Contact #{uuid.inspect}"
        find_one(type, uuid, '$top' => 1)
      end
    end

    def find_in_cache(type, uuids)
      keys = cache_keys(type, uuids)
      Rails.cache.read_multi(*keys).values.index_by(&:id)
    end

    def cached_find_many(type, uuids)
      hits = find_in_cache(type, uuids)
      misses = uuids - hits.keys

      unless misses.empty?
        crmlog "READING #{type.name.split('::').last.pluralize} #{misses.inspect}"

        entities = find_many(type, misses, '$top' => misses.length).index_by(&:id)

        entities.each do |id, entity|
          Rails.cache.write(cache_key(type, id), entity, expires_in: EXPIRATION)
        end
      end

      uuids.map { |id| hits[id] || entities[id] }.compact
    end

    def cache_enabled?
      Rails.application.config.x.gitis.caching
    end

    def cache_keys(type, uuids)
      uuids.map do |uuid|
        cache_key type, uuid
      end
    end

    def remove_from_cache(type, uuids)
      cache_keys(type, uuids).each do |key|
        Rails.cache.delete key
      end
    end

    def cache_key(type, uuid)
      "#{type.model_name.cache_key}/#{uuid}/#{version}"
    end

    def version
      "v1"
    end
  end
end
