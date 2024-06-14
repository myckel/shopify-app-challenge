class ShopifySyncJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform
    shop = Shop.first
    ShopifySyncService.new(shop).sync_products if shop
  end
end
