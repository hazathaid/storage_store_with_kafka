# spec/services/product_kafka_producer_service_spec.rb
require "rails_helper"

RSpec.describe ProductKafkaProducerService do
  let(:params) do
    {
      id: 1,
      code: "P001",
      name: "Product 1",
      price: 10.0,
      stock: 100,
      description: "Sample description",
      action: "create"
    }
  end

  describe ".build_payload" do
    it "returns correct JSON payload" do
      payload = described_class.build_payload(params)
      expect(JSON.parse(payload)).to eq(
        "id" => 1,
        "code" => "P001",
        "name" => "Product 1",
        "stock" => 100,
        "price" => 10.0,
        "description" => "Sample description",
        "action" => "create"
      )
    end
  end

  describe ".call" do
    let(:payload) { described_class.build_payload(params) }
    let(:producer) { double("Producer") }

    before do
      # stub Karafka.producer biar gak beneran kirim ke Kafka
      allow(Karafka).to receive(:producer).and_return(producer)
      allow(producer).to receive(:produce_async)
    end

    it "produces a message with correct topic and payload" do
      expect(producer).to receive(:produce_async).with(
        topic: "data_product",
        payload: payload
      )

      result = described_class.call(params)
      expect(result).to eq(payload)
    end

    it "returns the payload after producing" do
      result = described_class.call(params)
      expect(result).to eq(payload)
    end

    it "raises error if producer fails" do
      allow(producer).to receive(:produce_async).and_raise(StandardError.new("fail"))

      expect { described_class.call(params) }.to raise_error(StandardError, "fail")
    end
  end
end
