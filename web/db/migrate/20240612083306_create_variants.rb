class CreateVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :title
      t.string :sku
      t.decimal :price
      t.integer :inventory_quantity
      t.bigint :shopify_id
      t.bigint :inventory_item_id

      t.timestamps
    end
  end
end
