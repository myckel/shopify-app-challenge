# spec/services/snapshot_service_spec.rb
require 'rails_helper'

RSpec.describe SnapshotService do
  let(:shop) { instance_double(Shop, shopify_domain: 'example.myshopify.com', shopify_token: 'shpca_1234567890') }
  let(:session) { instance_double(ShopifyAPI::Auth::Session, shop: shop.shopify_domain, access_token: shop.shopify_token) }
  let(:snapshot_service) { described_class.new }
  let(:products) { [shopify_product, shopify_product] }
  let(:shopify_product) do
    instance_double(ShopifyAPI::Product,
      id: 1,
      title: 'Test Product',
      body_html: '<p>Description</p>',
      variants: [shopify_variant],
      images: [shopify_image],
      as_json: {
        'id' => 1,
        'title' => 'Test Product',
        'body_html' => '<p>Description</p>',
        'variants' => [
          {
            'id' => 1,
            'title' => 'Test Variant',
            'price' => '19.99',
            'sku' => '12345',
            'inventory_quantity' => 10,
            'inventory_item_id' => 1
          }
        ],
        'images' => [{'src' => 'http://example.com/image1.jpg'}]
      }
    )
  end
  let(:shopify_variant) do
    instance_double(ShopifyAPI::Variant,
      id: 1,
      title: 'Test Variant',
      price: '19.99',
      sku: '12345',
      inventory_quantity: 10,
      inventory_item_id: 1
    )
  end
  let(:shopify_image) { instance_double(ShopifyAPI::Image, src: 'http://example.com/image1.jpg') }

  before do
    allow(Shop).to receive(:first).and_return(shop)
    allow(ShopifyAPI::Auth::Session).to receive(:new).and_return(session)
    allow(ShopifyAPI::Context).to receive(:setup)
    allow(ShopifyAPI::Context).to receive(:activate_session).with(session)
    allow(ShopifyAPI::Product).to receive(:all).and_return(products)
    allow(ShopifyAPI::Product).to receive(:next_page?).and_return(false)
  end

  describe '#create_snapshot' do
    it 'creates a snapshot with all product data' do
      allow_any_instance_of(Snapshot).to receive(:save).and_return(true)
      expect(Rails.logger).to receive(:info).with(/Snapshot All Products Snapshot/)
      snapshot_service.create_snapshot
    end

    it 'logs an error if the snapshot fails to save' do
      allow_any_instance_of(Snapshot).to receive(:save).and_return(false)
      allow_any_instance_of(Snapshot).to receive_message_chain(:errors, :full_messages).and_return(['Error message'])
      expect(Rails.logger).to receive(:error).with(/Failed to create snapshot/)
      snapshot_service.create_snapshot
    end
  end

  describe '#fetch_all_product_data' do
    it 'fetches all product data from Shopify' do
      result = snapshot_service.send(:fetch_all_product_data)
      expect(result).to be_an(Array)
      expect(result.first[:id]).to eq(1)
      expect(result.first[:title]).to eq('Test Product')
      expect(result.first[:variants].first[:title]).to eq('Test Variant')
      expect(result.first[:images].first).to eq('http://example.com/image1.jpg')
    end
  end
end
