$redis = Redis.new(url: ENV["REDIS_URL"])

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :size => 5 }
end
