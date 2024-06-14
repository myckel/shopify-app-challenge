class MockShopifyProduct
  attr_accessor :id, :title, :body_html, :images, :variants, :status

  def initialize(id:, title:, body_html:, status:)
    @id = id
    @title = title
    @body_html = body_html
    @status = status
    @images = []
    @variants = MockVariantsArray.new
  end

  def save!
    true
  end

  def delete
    true
  end
end

class MockShopifyVariant
  attr_accessor :id, :option1, :price, :sku, :inventory_item_id

  def initialize(id:, option1:, price:, sku:, inventory_item_id:)
    @id = id
    @option1 = option1
    @price = price
    @sku = sku
    @inventory_item_id = inventory_item_id
  end

  def save!
    true
  end
end

class MockShopifyImage
  attr_accessor :id, :attachment, :product_id, :filename

  def initialize(id:, attachment:, product_id:, filename: nil)
    @id = id
    @attachment = attachment
    @product_id = product_id
    @filename = filename
  end

  def save!
    true
  end
end

class MockVariantsArray
  def initialize
    @variants = []
  end

  def find
    @variants.first
  end

  def new(*args)
    MockShopifyVariant.new(*args)
  end

  def <<(variant)
    @variants << variant
  end
end

class MockShopifyInventoryLevel
  def set(body:)
    # Simulate the setting of inventory level
  end
end
