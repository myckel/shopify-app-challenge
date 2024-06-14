class AddColumnLocationIdToSnapshot < ActiveRecord::Migration[7.0]
  def change
    add_column :snapshots, :location_id, :string
  end
end
