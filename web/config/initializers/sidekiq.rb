Sidekiq.configure_server do |config|
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  config.redis = { url: redis_url }
  Sidekiq::Scheduler.reload_schedule!
end

Sidekiq.configure_client do |config|
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  config.redis = { url: redis_url }
end
