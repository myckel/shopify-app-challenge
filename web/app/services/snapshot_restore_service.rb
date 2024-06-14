class SnapshotRestoreService
  def initialize(snapshot, product_variants = {})
    @snapshot = snapshot
    @location_id = @snapshot.location_id
    @product_variants = product_variants
  end

  def call
    begin
      raise 'Product variants cannot be blank' if @product_variants.blank?

      product_data = @snapshot.product_data

      selected_product_data = product_data.select { |product| @product_variants.keys.map(&:to_i).include?(product['id']) }
      selected_product_data.each do |product|
        restore_product(product)
      end
    rescue StandardError => e
      Rails.logger.error("Failed to restore snapshot: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    end
  end

  private

  def restore_product(product)
    shopify_product = ShopifyAPI::Product.find(id: product['id']) rescue nil
    shopify_product ? update_shopify_product(shopify_product, product) : create_shopify_product(product)

    shopify_product
  end

  def create_shopify_product(product)
    shopify_product = ShopifyAPI::Product.new
    shopify_product.title = product['title']
    shopify_product.body_html = product['description']
    shopify_product.save!

    shopify_product_ids = { old_id: product['id'], new_id: shopify_product.id }

    product['converted_images'].each do |image_data|
      upload_image_to_shopify(shopify_product.id, image_data)
    end

    variant_ids = []

    product['variants'].each do |variant_data|
      variant = find_or_create_variant(shopify_product, variant_data)
      variant_ids << {
        old_id: variant_data['id'],
        new_id: variant.id,
        inventory_item_id: variant.inventory_item_id
      }

      update_inventory_level(variant, variant_data)
    end

    update_snapshot_data(variant_ids, shopify_product_ids)

    shopify_product
  end

  def update_shopify_product(shopify_product, product)
    shopify_product.title = product['title']
    shopify_product.body_html = product['description']
    shopify_product.status = product.dig('status') || 'draft'
    shopify_product.save!

    images = shopify_product.images
    images.each do |image|
      ShopifyAPI::Image.delete(
        product_id: shopify_product.id,
        id: image.id,
      )
    end

    product['converted_images'].each do |image_data|
      upload_image_to_shopify(shopify_product.id, image_data)
    end

    variant_ids = []

    product['variants'].each do |variant_data|
      variant = find_or_create_variant(shopify_product, variant_data)
      variant_ids << {
        old_id: variant_data['id'],
        new_id: variant.id,
        inventory_item_id: variant.inventory_item_id
      }

      update_inventory_level(variant, variant_data)
    end

    update_snapshot_data(variant_ids)
  end

  def find_or_create_variant(shopify_product, variant_data)
    variant = shopify_product.variants.find { |v| v.option1 == variant_data['title'] } rescue nil

    if variant
      variant.option1 = variant_data['title']
      variant.price = variant_data['price']&.to_f
      variant.sku = variant_data['sku']
      variant.save!
    else
      variant = ShopifyAPI::Variant.new
      variant.product_id = shopify_product.id
      variant.option1 = variant_data['title']
      variant.price = variant_data['price'].to_f
      variant.sku = variant_data['sku']
      variant.save!
    end

    variant
  end

  def update_inventory_level(variant, variant_data)
    inventory_quantity = variant_data['inventory']
    inventory_item = ShopifyAPI::InventoryItem.find(id: variant.inventory_item_id)

    if inventory_item.tracked == false
      inventory_item.tracked = true
      inventory_item.save!
    end

    inventory_level = ShopifyAPI::InventoryLevel.new
    inventory_level.set(
      body: {
        location_id: @location_id,
        inventory_item_id: variant.inventory_item_id,
        available: inventory_quantity
      }
    )
  end

  def update_snapshot_data(variant_ids, shopify_product_ids = nil)
    product_data = @snapshot.product_data

    if shopify_product_ids
      product = product_data.find { |p| p['id'] == shopify_product_ids[:old_id] }
      product['id'] = shopify_product_ids[:new_id]
    end

    variant_ids.each do |variant_id|
      product = product_data.find { |p| p['id'] == variant_id[:id] }
      if product
        variant = product['variants'].find { |v| v['id'] == variant_id[:old_id] }
        if variant
          variant['id'] = variant_id[:new_id]
          variant['inventory_item_id'] = variant_id[:inventory_item_id]
        end
      end
    end

    @snapshot.update!(product_data: product_data)
  end

  def upload_image_to_shopify(product_id, image_data)
    image = ShopifyAPI::Image.new
    image.product_id = product_id
    image.attachment = image_data['attachment']
    image.filename = image_data['filename']
    image.save!
  end
end
