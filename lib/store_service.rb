require 'redis'

class StoreService
  attr_accessor :redis

  @@config = {
    host: "127.0.0.1",
    port: 6379,
    db_name: "NEWS_XML"
  }

  def initialize
    @redis = Redis.new(:host => @@config[:host], :port => @@config[:port])
  end

  # overwrites values if key already exists
  def store(key, data)
    redis.hset @@config[:db_name], key, data
  end
end
