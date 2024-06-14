require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:shopify_session) { instance_double("ShopifyAPI::Auth::Session") }
  let(:shopify_id_token) { "some-id-token" }

  before do
    allow(controller).to receive(:current_shopify_session).and_return(shopify_session)
    allow(controller).to receive(:shopify_id_token).and_return(shopify_id_token)
    allow(ShopifyAPI::Context).to receive(:activate_session).with(shopify_session)
  end

  describe "GET #index" do
    it "returns a list of products" do
      products = [double("ShopifyAPI::Product"), double("ShopifyAPI::Product")]
      allow(ShopifyAPI::Product).to receive(:all).and_return(products)

      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(products.to_json)
    end
  end

  describe "GET #count" do
    it "returns the product count" do
      product_count = { "count" => 10 }
      allow(ShopifyAPI::Product).to receive(:count).and_return(double(body: product_count))

      get :count
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(product_count.to_json)
    end
  end

  describe "POST #create" do
    context "when successful" do
      it "creates products and returns success" do
        allow(ProductCreator).to receive(:call).and_return(true)

        post :create
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ success: true, error: nil }.to_json)
      end
    end

    context "when there is an error" do
      it "returns an error message" do
        error_message = "An error occurred"
        allow(ProductCreator).to receive(:call).and_raise(StandardError.new(error_message))

        post :create
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to eq({ success: false, error: error_message }.to_json)
      end
    end
  end
end
