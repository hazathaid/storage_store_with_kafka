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
        "price" => 10.0,
        "stock" => 100,
        "description" => "Sample description",
        "action" => "create"
      )
    end

    it "includes all required keys in the payload" do
      payload = described_class.build_payload(params)
      parsed = JSON.parse(payload)
      expect(parsed.keys).to contain_exactly("id", "code", "name", "stock", "price", "description", "action")
    end

    it "serializes params to JSON without error" do
      payload = described_class.build_payload(params)
      expect { JSON.parse(payload) }.not_to raise_error
    end

    it "handles string and symbol keys in params" do
      string_key_params = params.transform_keys(&:to_s)
      payload = described_class.build_payload(string_key_params)
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
    let(:kafka_double) { double(Kafka) }

    before do
      allow(Kafka).to receive(:new).and_return(kafka_double)
      allow(kafka_double).to receive(:deliver_message)
    end

    it "initializes Kafka with correct brokers and client_id" do
      expect(Kafka).to receive(:new).with([ "localhost:9092" ], client_id: "storage_rails").and_return(kafka_double)
      described_class.call(params)
    end

    it "calls deliver_message with correct payload and topic" do
      payload = described_class.build_payload(params)
      expect(kafka_double).to receive(:deliver_message).with(payload, topic: "storage-product")
      described_class.call(params)
    end

    it "returns the payload after sending" do
      result = described_class.call(params)
      expect(result).to eq(described_class.build_payload(params))
    end

    it "raises error if Kafka connection fails" do
      allow(Kafka).to receive(:new).and_raise(Kafka::ConnectionError)
      expect { described_class.call(params) }.to raise_error(Kafka::ConnectionError)
    end
  end
end
