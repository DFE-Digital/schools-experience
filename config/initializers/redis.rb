# Test the Redis connection on boot
unless Redis.new.ping == "PONG"
  raise "Could not connect to Redis"
end