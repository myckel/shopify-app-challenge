Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
  Sidekiq::Scheduler.reload_schedule!
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end
