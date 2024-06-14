require 'rails_helper'
require 'support/shopify_api_mocks'

RSpec.describe SnapshotRestoreService do
  let(:shop) { double('Shop', shopify_domain: 'example.myshopify.com', shopify_token: 'shpca_1234567890') }
  let(:session) { instance_double(ShopifyAPI::Auth::Session, shop: shop.shopify_domain, access_token: shop.shopify_token) }
  let(:service) { described_class.new(shop) }
  let(:shopify_product) { MockShopifyProduct.new(id: 1, title: 'Test Product', body_html: '<p>Description</p>', status: 'active') }
  let(:shopify_variant) { MockShopifyVariant.new(id: 1, option1: 'Test Variant', price: '19.99', sku: '12345', inventory_item_id: 1) }
  let(:shopify_image) { MockShopifyImage.new(id: 1, attachment: 'fake image data', product_id: 1, filename: 'image1.jpg') }
  let(:shopify_location) { instance_double(ShopifyAPI::Location, id: 1) }
  let(:shopify_inventory_item) { instance_double(ShopifyAPI::InventoryItem, id: 1, tracked: true) }
  let(:shopify_inventory_level) { MockShopifyInventoryLevel.new }
  let(:snapshot) { create(:snapshot, product_data: [product_data]) }
  let(:product_data) do
    {
      'id' => 1,
      'title' => 'Test Product',
      'description' => '<p>Description</p>',
      'status' => 'active',
      'converted_images' => [
        {
          'filename' => 'image1.jpg',
          'attachment' => Base64.encode64('fake image data')
        }
      ],
      'variants' => [
        {
          'id' => 1,
          'title' => 'Test Variant',
          'price' => '19.99',
          'sku' => '12345',
          'inventory_item_id' => 1,
          'inventory_quantity' => 10
        }
      ]
    }
  end
  let(:product_variants) { { '1' => ['1'] } }

  before do
    allow(ShopifyAPI::Auth::Session).to receive(:new).and_return(session)
    allow(ShopifyAPI::Context).to receive(:setup)
    allow(ShopifyAPI::Context).to receive(:activate_session).with(session)
    ShopifyAPI::Context.activate_session(session)

    allow(ShopifyAPI::Product).to receive(:find).and_return(shopify_product)
    allow(ShopifyAPI::Product).to receive(:new).and_return(shopify_product)
    allow(shopify_product.variants).to receive(:find).and_return(shopify_variant)
    allow(shopify_product.variants).to receive(:new).and_return(shopify_variant)
    allow(ShopifyAPI::Image).to receive(:new).and_return(shopify_image)
    allow(ShopifyAPI::Location).to receive(:all).and_return([shopify_location])
    allow(ShopifyAPI::InventoryItem).to receive(:find).and_return(shopify_inventory_item)
    allow(ShopifyAPI::InventoryLevel).to receive(:new).and_return(shopify_inventory_level)
  end

  describe '#call' do
    context 'when product variants are present' do
      it 'restores the product' do
        service = SnapshotRestoreService.new(snapshot, product_variants)
        expect { service.call }.not_to raise_error
      end
    end
  end

  describe '#restore_product' do
    context 'when the product exists' do
      it 'calls update_shopify_product' do
        service = SnapshotRestoreService.new(snapshot, product_variants)
        expect(service).to receive(:update_shopify_product).with(shopify_product, product_data)
        service.send(:restore_product, product_data)
      end
    end

    context 'when the product does not exist' do
      before do
        allow(ShopifyAPI::Product).to receive(:find).and_return(nil)
      end

      it 'calls create_shopify_product' do
        service = SnapshotRestoreService.new(snapshot, product_variants)
        expect(service).to receive(:create_shopify_product).with(product_data)
        service.send(:restore_product, product_data)
      end
    end
  end

  describe '#create_shopify_product' do
    it 'creates a new Shopify product' do
      service = SnapshotRestoreService.new(snapshot, product_variants)
      expect(shopify_product).to receive(:title=).with('Test Product')
      expect(shopify_product).to receive(:body_html=).with('<p>Description</p>')
      expect(shopify_product).to receive(:save!)
      service.send(:create_shopify_product, product_data)
    end
  end

  describe '#update_shopify_product' do
    it 'updates the Shopify product' do
      service = SnapshotRestoreService.new(snapshot, product_variants)
      expect(shopify_product).to receive(:title=).with('Test Product')
      expect(shopify_product).to receive(:body_html=).with('<p>Description</p>')
      expect(shopify_product).to receive(:status=).with('active')
      expect(shopify_product).to receive(:save!)
      service.send(:update_shopify_product, shopify_product, product_data)
    end
  end
end
