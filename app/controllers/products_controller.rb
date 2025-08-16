class ProductsController < ApplicationController
  def create
    kafka = Kafka.new([ "localhost:9092" ], client_id: "storage_rails")
    data = {
      code: params[:code],
      name: params[:name],
      stock: params[:stock],
      price: params[:price],
      description: params[:description]
    }.to_json
     kafka.deliver_message(data, topic: "storage-product")
     render json: { status: "Product Successfully sent to Kafka", data: data }
  end
end
