require 'rails_helper'

RSpec.describe Snapshot, type: :model do
  subject {
    described_class.new(
      name: "Test Snapshot",
      product_data: [
        {
          "images" => ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
          "converted_images" => []
        }
      ]
    )
  }

  # Validations
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:product_data) }

  # Callbacks
  describe "callbacks" do
    before do
      allow(ShopifyAPI::Location).to receive(:all).and_return([double("ShopifyAPI::Location", id: 123)])
    end

    it "calls set_location before save if location_id is blank" do
      subject.location_id = nil
      expect(subject).to receive(:set_location)
      subject.save
    end

    it "calls download_images before save" do
      expect(subject).to receive(:download_images)
      subject.save
    end
  end

  # Methods
  describe "#download_images" do
    let(:image_url) { "https://example.com/image1.jpg" }

    before do
      allow(URI).to receive(:open).and_return(StringIO.new("image data"))
      allow(Base64).to receive(:encode64).and_return("base64encodeddata")
    end

    it "downloads and encodes images" do
      subject.send(:download_images)
      expect(subject.product_data.first["converted_images"]).to eq([
        {
          filename: "image1.jpg",
          attachment: "base64encodeddata"
        },
        {
          filename: "image2.jpg",
          attachment: "base64encodeddata"
        }
      ])
    end
  end

  describe "#set_location" do
    let(:location) { double("ShopifyAPI::Location", id: 123) }

    before do
      allow(ShopifyAPI::Location).to receive(:all).and_return([location])
    end

    it "sets the location_id to the first location's id" do
      subject.send(:set_location)
      expect(subject.location_id).to eq(123.to_s)
    end
  end
end
