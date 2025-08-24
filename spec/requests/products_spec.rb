require "rails_helper"

RSpec.describe "Products", type: :request do
  let(:valid_attributes) do
    {
      code: "P001",
      name: "Product 1",
      price: 10.0,
      stock: 100,
      description: "Sample description"
    }
  end

  describe "POST /products (JSON)" do
    it "calls ProductKafkaProducerService with correct params and return json" do
      expect(ProductKafkaProducerService).to receive(:call).with(hash_including(valid_attributes.merge(action: "create")))

      post products_path, params: { product: valid_attributes }, as: :json

      expect(response).to have_http_status(:ok) # karena kamu pakai render json default 200
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Product Successfully sent to Kafka")
    end
  end

  describe "POST /products (HTML)" do
    it "calls ProductKafkaProducerService with correct params and redirect to index" do
      expect(ProductKafkaProducerService).to receive(:call) do |params|
        expect(params.to_h).to include(
          "code" => "P001",
          "name" => "Product 1",
          "price" => "10.0",
          "stock" => "100",
          "description" => "Sample description",
          "action" => "create"
        )
      end


      post products_path, params: { product: valid_attributes }

      expect(response).to redirect_to(products_url)
      follow_redirect!
      expect(response.body).to include("Product created successfully")
    end
  end

  describe "PATCH /products/:id" do
    let(:product) { Product.create!(valid_attributes) } # hanya untuk kasih ID (set_product butuh data)

    it "calls ProductKafkaProducerService with correct params" do
      updated = valid_attributes.merge(name: "Updated", action: "update")

      expect(ProductKafkaProducerService).to receive(:call).with(hash_including(updated.stringify_keys))

      patch product_path(product), params: { product: updated.except(:action) }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Product Successfully sent to Kafka")
    end
  end

  describe "DELETE /products/:id" do
    let(:product) { Product.create!(valid_attributes) }

    it "calls ProductKafkaProducerService with correct params" do
      expect(ProductKafkaProducerService).to receive(:call).with(hash_including(id: product.id.to_s, action: "destroy"))

      delete product_path(product), as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("Product Successfully sent to Kafka")
    end
  end
end
