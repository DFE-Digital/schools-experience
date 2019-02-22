# This is adapted from the Geocoder examples dir
class AutoexpireCacheRedis
  def initialize(store, ttl = 1.month.to_i)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.get(url)
  end

  def []=(url, value)
    @store.set(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end
