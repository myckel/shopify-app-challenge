class LocalProductsController < ApplicationController
  # GET /api/products/local
  def index
    @products = Product.all
    render json: @products, each_serializer: ProductSerializer
  end
end
