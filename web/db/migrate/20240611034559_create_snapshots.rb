class CreateSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :snapshots do |t|
      t.string :name
      t.jsonb :product_data

      t.timestamps
    end
  end
end
