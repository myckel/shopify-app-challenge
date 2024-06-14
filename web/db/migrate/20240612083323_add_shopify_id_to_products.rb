class AddShopifyIdToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :shopify_id, :bigint
    add_column :products, :status, :string
  end
end
