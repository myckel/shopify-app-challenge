class SnapshotsController < AuthenticatedController
  before_action :set_snapshot, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @snapshots = Snapshot.all
    render json: @snapshots, each_serializer: SnapshotSerializer
  end

  def show
    render json: @snapshot, serializer: SnapshotSerializer
  end

  def create
    snapshot = Snapshot.new(
      name: snapshot_params[:name],
      product_data: snapshot_params[:product_data]
    )

    if snapshot.save
      render json: snapshot, serializer: SnapshotSerializer, status: :created
    else
      render json: snapshot.errors, status: :unprocessable_entity
    end
  end

  def update
    if @snapshot.update(snapshot_params)
      render json: @snapshot, serializer: SnapshotSerializer
    else
      render json: @snapshot.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @snapshot.destroy
    head :no_content
  end

  def restore
    product_variants = params[:product_variants] || {}

    SnapshotRestoreService.new(@snapshot, product_variants).call

    render json: { message: 'Product data restored successfully' }, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to restore product data: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end

  def snapshot_params
    params.require(:snapshot).permit(
      :name,
      :created_at,
      product_data: [
        :title,
        :description,
        :price,
        :inventory,
        :id,
        :internal_id,
        :type,
        :status,
        images: [],
        variants: [
          :inventory_item_id,
          :internal_id,
          :sku,
          :title,
          :price,
          :inventory,
          :id,
          :type
        ]
      ]
    )
  end
end
