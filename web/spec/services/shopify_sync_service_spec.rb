require 'rails_helper'

RSpec.describe ShopifySyncService do
  let(:shop) { double('Shop', shopify_domain: 'example.myshopify.com', shopify_token: 'shpca_1234567890') }
  let(:session) { instance_double(ShopifyAPI::Auth::Session, shop: shop.shopify_domain, access_token: shop.shopify_token) }
  let(:service) { described_class.new(shop) }

  before do
    allow(ShopifyAPI::Auth::Session).to receive(:new).and_return(session)
    allow(ShopifyAPI::Context).to receive(:setup)
    allow(ShopifyAPI::Context).to receive(:activate_session)
  end

  describe '#sync_products' do
    let(:shopify_product) { instance_double(ShopifyAPI::Product, id: 1, title: 'Test Product', status: 'active', body_html: '<p>Description</p>', images: [instance_double(ShopifyAPI::Image, src: 'image.jpg')], variants: [shopify_variant]) }
    let(:shopify_variant) { instance_double(ShopifyAPI::Variant, id: 1, title: 'Test Variant', sku: '12345', price: '19.99', inventory_quantity: 10, inventory_item_id: 1) }

    before do
      allow(ShopifyAPI::Product).to receive(:all).and_return([shopify_product])
      allow(ShopifyAPI::Product).to receive(:next_page?).and_return(false)
    end

    it 'saves the Shopify product data to the local database' do
      expect { service.sync_products }.to change(Product, :count).by(1)
      product = Product.last
      expect(product.title).to eq(shopify_product.title)
      expect(product.status).to eq(shopify_product.status)
      expect(product.description).to eq(shopify_product.body_html)
      expect(product.image).to eq(shopify_product.images.first.src)
      expect(product.price.to_s).to eq(shopify_product.variants.first.price)
      expect(product.inventory_level).to eq(shopify_product.variants.sum(&:inventory_quantity))
    end

    it 'calls save_variant for each Shopify variant' do
      allow(service).to receive(:save_variant)
      service.sync_products
      expect(service).to have_received(:save_variant).with(kind_of(Product), shopify_variant)
    end
  end

  describe '#save_variant' do
    let(:product) { create(:product) }
    let(:shopify_variant) { instance_double(ShopifyAPI::Variant, id: 1, title: 'Test Variant', sku: '12345', price: '19.99', inventory_quantity: 10, inventory_item_id: 1) }

    it 'saves the Shopify variant data to the local database' do
      expect { service.send(:save_variant, product, shopify_variant) }.to change(Variant, :count).by(1)
      variant = Variant.last
      expect(variant.title).to eq(shopify_variant.title)
      expect(variant.sku).to eq(shopify_variant.sku)
      expect(variant.price.to_s).to eq(shopify_variant.price)
      expect(variant.inventory_quantity).to eq(shopify_variant.inventory_quantity)
      expect(variant.inventory_item_id).to eq(shopify_variant.inventory_item_id)
    end
  end
end
