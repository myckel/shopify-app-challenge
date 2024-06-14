class SnapshotService
  def initialize
    @shop = Shop.first
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

  def create_snapshot
    snapshot_name = "All Products Snapshot #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}"
    product_data = fetch_all_product_data

    snapshot = Snapshot.new(
      name: snapshot_name,
      product_data: product_data
    )

    if snapshot.save
      Rails.logger.info "Snapshot #{snapshot_name} created successfully."
    else
      Rails.logger.error "Failed to create snapshot: #{snapshot.errors.full_messages.join(', ')}"
    end
  end

  private

  def fetch_all_product_data
    all_products = []
    products = ShopifyAPI::Product.all(session: @session, limit: 250)

    loop do
      all_products.concat(products.map(&:as_json))
      break unless ShopifyAPI::Product.next_page?
      products = ShopifyAPI::Product.all(session: @session, limit: 250, page_info: ShopifyAPI::Product.next_page_info)
    end

    all_products.map { |product| map_product_data(product) }
  end

  def map_product_data(product)
    {
      id: product['id'],
      type: 'Product',
      price: product['variants'][0]['price'],
      title: product['title'],
      images: product['images'].map { |image| image['src'] },
      variants: product['variants'].map { |variant| map_variant_data(variant) },
      description: product['body_html']
    }
  end

  def map_variant_data(variant)
    {
      id: variant['id'],
      sku: variant['sku'],
      type: 'Variant',
      price: variant['price'],
      title: variant['title'],
      inventory: variant['inventory_quantity'],
      inventory_item_id: variant['inventory_item_id']
    }
  end
end
