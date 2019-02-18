# Test the Redis connection on boot
unless ENV['SKIP_REDIS'].present? || Redis.current.ping == "PONG"
  raise "Could not connect to Redis"
end
