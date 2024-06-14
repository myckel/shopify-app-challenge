FactoryBot.define do
  factory :variant do
    title { "Test Variant" }
    sku { "12345" }
    price { "19.99" }
    inventory_quantity { 10 }
    inventory_item_id { 1 }
    shopify_id { 1 }
    product
  end
end
