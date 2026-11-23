# Errors raised when Redis (or the network path to it) fails transiently
TRANSIENT_REDIS_ERRORS = [
  Redis::BaseError,
  SystemCallError, # e.g. Errno::ETIMEDOUT from a dropped TLS connection
  IOError,
  SocketError,
  OpenSSL::SSL::SSLError,
].freeze

# Test the Redis connection on boot
if ENV['SKIP_REDIS'].blank?
  REDIS = ConnectionPool::Wrapper.new(size: 5, timeout: 3) do
    Redis.new(
      db: (Rails.env.test? ? ENV['TEST_ENV_NUMBER'].presence : nil),
      connect_timeout: 20, # Default is 5s but logic is we're better being slower booting than failing to boot
      tcp_keepalive: 60, # Turn keep alive on, ping after 40 seconds, try twice, 10 seconds apart, before giving up - then fall through to reconnect attemp
      reconnect_attempts: 1, # Allow for connection failure since Azure networking to Redis is showing some unreliability
      reconnect_delay: 0.5, # Back off before reconnecting so the retry is not made inside the same network blip
      reconnect_delay_max: 0.5,
      read_timeout: 1, # Fail fast rather than holding a Puma thread through a blip
      write_timeout: 1
    )
  end

  unless REDIS.ping == "PONG"
    raise "Could not connect to Redis"
  end
end
