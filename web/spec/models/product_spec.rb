require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should have_many(:variants).dependent(:destroy) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:inventory_level) }

  describe "validations" do
    let(:product) { build(:product) }

    it "is valid with valid attributes" do
      expect(product).to be_valid
    end

    it "is not valid without a title" do
      product.title = nil
      expect(product).not_to be_valid
      expect(product.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a price" do
      product.price = nil
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it "is not valid without an inventory level" do
      product.inventory_level = nil
      expect(product).not_to be_valid
      expect(product.errors[:inventory_level]).to include("can't be blank")
    end
  end
end
