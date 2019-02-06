require 'redis_conn'

RedisConn.connect(ENV['REDIS_URL'])
RedisConn.test!
