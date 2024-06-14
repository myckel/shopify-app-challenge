FactoryBot.define do
  factory :shop do
    shopify_domain { "test-shop.myshopify.com" }
    shopify_token { "shpat_1234567890abcdef1234567890abcdef" }
  end
end
