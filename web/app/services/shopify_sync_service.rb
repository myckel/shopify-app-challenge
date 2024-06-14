require 'open-uri'
class ShopifySyncService
  def initialize(shop)
    @shop = shop
    @session = ShopifyAPI::Auth::Session.new(
      shop: @shop.shopify_domain,
      access_token: @shop.shopify_token
    )
    ShopifyAPI::Context.setup(
      api_key: ENV['SHOPIFY_API_KEY'],
      api_secret_key: ENV['SHOPIFY_API_SECRET'],
      api_version: '2024-04',
      scope: 'read_inventory,read_orders,read_products',
      is_private: false,
      is_embedded: true
    )
    ShopifyAPI::Context.activate_session(@session)
  end

  def sync_products
    products = ShopifyAPI::Product.all(session: @session, limit: 250)
    loop do
      products.each { |product| save_product(product) }
      break unless ShopifyAPI::Product.next_page?
      products = ShopifyAPI::Product.all(session: @session, limit: 250, page_info: ShopifyAPI::Product.next_page_info)
    end
  end

  private

  def save_product(shopify_product)
    product = Product.find_or_initialize_by(shopify_id: shopify_product.id)
    product.title = shopify_product.title
    product.status = shopify_product.status
    product.description = shopify_product.body_html
    product.image = encode_image_to_base64(shopify_product.images.first&.src)
    product.price = shopify_product.variants.first&.price
    product.inventory_level = shopify_product.variants.sum(&:inventory_quantity)
    product.save!

    shopify_product.variants.each do |variant|
      save_variant(product, variant)
    end
  end

  def save_variant(product, shopify_variant)
    variant = product.variants.find_or_initialize_by(shopify_id: shopify_variant.id)
    variant.title = shopify_variant.title
    variant.sku = shopify_variant.sku
    variant.price = shopify_variant.price
    variant.inventory_quantity = shopify_variant.inventory_quantity
    variant.inventory_item_id = shopify_variant.inventory_item_id
    variant.save!
  end

  def encode_image_to_base64(image_url)
    return nil if image_url.nil?

    begin
      image_data = URI.open(image_url).read
      Base64.encode64(image_data)
    rescue => e
      Rails.logger.error "Failed to encode image to Base64: #{e.message}"
      nil
    end
  end
end
