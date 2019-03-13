# This is adapted from the Geocoder examples dir but
# it wraps Rails.cache instead of Redis.current
class GeocoderAutoexpireCache
  attr_accessor :store, :ttl

  def initialize(store, ttl = 1.month)
    self.store = store
    self.ttl = ttl
  end

  def [](url)
    store.read(url)
  end

  def []=(url, value)
    store.write(url, value, expires_in: ttl)
  end

  def keys
    store.redis.keys
  end

  def del(url)
    store.delete(url)
  end
end
