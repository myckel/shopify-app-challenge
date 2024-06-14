FactoryBot.define do
  factory :shop do
    shopify_domain { "test-shop.myshopify.com" }
    shopify_token { "test-token-shopify" }
  end
end
