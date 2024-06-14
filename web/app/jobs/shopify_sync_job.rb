class ShopifySyncJob < ApplicationJob
  include Sidekiq::Job
  queue_as :default

  def perform
    shop = Shop.first
    ShopifySyncService.new(shop).sync_products if shop
  end
end
