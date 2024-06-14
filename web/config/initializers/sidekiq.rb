require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  config.redis = { url: redis_url }
  config.on(:startup) do
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  config.redis = { url: redis_url }
end
