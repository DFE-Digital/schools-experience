# Test the Redis connection on boot
unless ENV['SKIP_REDIS'].present? || Redis.new.ping == "PONG"
  raise "Could not connect to Redis"
end
