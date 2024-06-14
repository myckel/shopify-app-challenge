class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :location_id, :product_data

  def product_data
    object.product_data.map do |product|
      product.except("converted_images")
    end
  end
end
