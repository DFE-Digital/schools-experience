class RedisConn
  class_attribute :connection

  class << self
    def connect(url = nil)
      self.connection = Redis.new(url: url)
    end

    def redis
      connection || raise("Not Connected to Redis, call #{self}.connect(my_redis_url)")
    end

    def test!
      ping
      true
    end

    def respond_to_missing?(name, include_private = false)
      redis.respond_to?(name) || super
    end

    def method_missing(method, *args, &block)
      redis.send(method, *args, &block)
    end
  end
end
