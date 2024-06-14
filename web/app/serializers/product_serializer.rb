class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image, :price, :inventory_level

  has_many :variants
end
