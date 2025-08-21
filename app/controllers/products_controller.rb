class ProductsController < ApplicationController
  before_action :set_product, only: [ :edit, :update, :destroy ]
  def index
    @products = Product.all
  end
  def new
    @product = Product.new
  end

  def create
    result = ProductKafkaProducerService.call(product_params.merge(action: "create"))
    if request.format.json?
      render json: { status: "Product Successfully sent to Kafka", data: result }
    else
      redirect_to products_url, notice: "Product created successfully"
    end
  end

  def edit
  end

  def update
    result = ProductKafkaProducerService.call(product_params.merge(action: "update"))
    if request.format.json?
      render json: { status: "Product Successfully sent to Kafka", data: result }
    else
      redirect_to products_url, notice: "Product updated successfully"
    end
  end

  def destroy
    result = ProductKafkaProducerService.call(id: params[:id], action: "destroy")
    if request.format.json?
      render json: { status: "Product Successfully sent to Kafka", data: result }
    else
      redirect_to products_url, notice: "Product deleted successfully"
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:code, :name, :price, :stock, :description)
  end
end
