FactoryBot.define do
  factory :product do
    title { "Sample Product" }
    price { 9.99 }
    inventory_level { 100 }
  end
end
