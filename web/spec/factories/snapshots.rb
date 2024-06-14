FactoryBot.define do
  factory :snapshot do
    name { "Snapshot Test" }
    product_data { [
      {
        title: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        inventory: 5,
        id: 1,
        internal_id: 'internal_1',
        type: 'product',
        status: 'active',
        images: ['image1.jpg'],
        variants: [
          {
            inventory_item_id: 1,
            internal_id: 'variant_internal_1',
            sku: 'SKU1',
            title: 'Variant 1',
            price: 5.0,
            inventory: 10,
            id: 1,
            type: 'variant'
          }
        ]
      }
    ]}
  end
end
