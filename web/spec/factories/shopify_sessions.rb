FactoryBot.define do
  factory :shopify_session, class: 'ShopifyAPI::Auth::Session' do
    shop { "test-shop.myshopify.com" }
    access_token { "test-access-token" }
    is_online { false }
    scope { "read_products,write_products" }

    initialize_with do
      new(
        id: "15fd1e5a-920a-418a-84f1-3c5b60830e34",
        shop: shop,
        access_token: access_token,
        scope: scope,
        is_online: is_online
      )
    end
  end
end
