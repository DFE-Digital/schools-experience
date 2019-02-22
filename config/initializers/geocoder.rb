require Rails.root.join('lib', 'autoexpire_cache_redis')

Geocoder.configure(
  # street address geocoding service (default :nominatim)
  # lookup: :yandex,

  # IP address geocoding service (default :ipinfo_io)
  # ip_lookup: :maxmind,

  # to use an API key:
  # api_key: "...",

  # geocoding service request timeout, in seconds (default 3):
  # timeout: 5,

  units: :miles,

  # caching (see [below](#caching) for details):
  cache: AutoexpireCacheRedis.new(Redis.new(url: ENV['REDIS_CACHE_URL'].presence)),
  cache_prefix: "geocoder:"
)
