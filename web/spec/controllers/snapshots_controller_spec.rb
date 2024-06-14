require 'rails_helper'
require 'shopify_api'
require 'open-uri'

RSpec.describe SnapshotsController, type: :controller do
  let(:valid_attributes) do
    {
      name: "Snapshot Test",
      product_data: [
        { title: "Product 1", description: "Description 1", price: "10.00", inventory: 100 },
        { title: "Product 2", description: "Description 2", price: "20.00", inventory: 200 }
      ]
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      product_data: []
    }
  end

  let!(:shopify_session) { build(:shopify_session) }
  let(:locations) { [double("ShopifyAPI::Location", id: 1, name: "Location 1")] }

  before do
    allow(controller).to receive(:current_shopify_session).and_return(shopify_session)
    allow(ShopifyAPI::Context).to receive(:active_session).and_return(shopify_session)
    allow(ShopifyAPI::Auth::Session).to receive(:new).and_return(shopify_session)
    allow(ShopifyAPI::Location).to receive(:all).and_return(locations)
    ShopifyAPI::Context.activate_session(shopify_session)
    allow_any_instance_of(Snapshot).to receive(:download_images).and_return(true)
  end

  describe "GET #index" do
    it "returns a success response" do
      snapshot = create(:snapshot)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      snapshot = create(:snapshot)
      get :show, params: { id: snapshot.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
  context "with valid params" do
    it "creates a new Snapshot" do
      expect {
        post :create, params: { snapshot: valid_attributes }
      }.to change(Snapshot, :count).by(1)
    end

    it "renders a JSON response with the new snapshot" do
      post :create, params: { snapshot: valid_attributes }
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  context "with invalid params" do
    it "renders a JSON response with errors for the new snapshot" do
      post :create, params: { snapshot: { name: nil, product_data: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)).to include("name", "product_data")
    end
  end
end


  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        {
          name: "Updated Snapshot",
          product_data: [
            { title: "Updated Product 1", description: "Updated Description 1", price: "15.00", inventory: 150 }
          ]
        }
      end

      it "updates the requested snapshot" do
        snapshot = create(:snapshot)
        put :update, params: { id: snapshot.to_param, snapshot: new_attributes }
        snapshot.reload
        expect(snapshot.name).to eq("Updated Snapshot")
      end

      it "renders a JSON response with the snapshot" do
        snapshot = create(:snapshot)
        put :update, params: { id: snapshot.to_param, snapshot: valid_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the snapshot" do
        snapshot = create(:snapshot)
        put :update, params: { id: snapshot.to_param, snapshot: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested snapshot" do
      snapshot = create(:snapshot)
      expect {
        delete :destroy, params: { id: snapshot.to_param }
      }.to change(Snapshot, :count).by(-1)
    end
  end

  describe "POST #restore" do
  it "restores the snapshot" do
    snapshot = create(:snapshot)
    allow_any_instance_of(SnapshotRestoreService).to receive(:call).and_return(true)
    post :restore, params: { id: snapshot.to_param, product_variants: {} }
    expect(response).to have_http_status(:ok)
  end

  it "returns an error message when restoration fails" do
    snapshot = create(:snapshot)
    allow_any_instance_of(SnapshotRestoreService).to receive(:call).and_raise(StandardError.new("Restoration failed"))
    post :restore, params: { id: snapshot.to_param, product_variants: {} }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)["error"]).to eq("Failed to restore product data: Restoration failed")
  end
end

end
