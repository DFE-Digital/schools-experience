# Test the Redis connection on boot
if ENV['SKIP_REDIS'].blank?
  REDIS = ConnectionPool::Wrapper.new(size: 5, timeout: 3) do
    Redis.new(
      db: (Rails.env.test? ? ENV['TEST_ENV_NUMBER'].presence : nil),
      connect_timeout: 20, # Default is 5s but logic is we're better being slower booting than failing to boot
      tcp_keepalive: 60, # Turn keep alive on, ping after 40 seconds, try twice, 10 seconds apart, before giving up - then fall through to reconnect attemp
      reconnect_attempts: 1 # Allow for connection failure since Azure networking to Redis is showing some unreliability
    )
  end

  unless REDIS.ping == "PONG"
    raise "Could not connect to Redis"
  end
end
