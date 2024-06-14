class VariantSerializer < ActiveModel::Serializer
  attributes :id, :sku, :price, :title, :inventory_quantity, :inventory_item_id
end
