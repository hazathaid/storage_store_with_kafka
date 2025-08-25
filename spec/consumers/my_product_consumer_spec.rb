# spec/consumers/my_product_consumer_spec.rb
require "rails_helper"

RSpec.describe MyProductConsumer do
  let(:consumer) { described_class.new }

  let(:product_data) do
    {
      code: "P001",
      name: "Product 1",
      price: 10.0,
      stock: 100,
      description: "Sample description",
      action: "create"
    }
  end

  let(:destroy_data) do
    {
      id: "123",
      action: "destroy"
    }
  end

  let(:product_message) { double("Karafka::Message", payload: product_data.to_json) }
  let(:destroy_message) { double("Karafka::Message", payload: destroy_data.to_json) }

  describe "#consume" do
    it "logs consuming and processing, calls ProductSyncService, and logs success for create" do
      allow(consumer).to receive(:messages).and_return([ product_message ])

      service = instance_double(ProductSyncService)
      expect(Rails.logger).to receive(:info).with("Consuming messages from MyProductConsumer")
      expect(Rails.logger).to receive(:info).with(/Processing message:/)
      expect(ProductSyncService).to receive(:new).with(hash_including(product_data)).and_return(service)
      expect(service).to receive(:call)
      expect(Rails.logger).to receive(:info).with("Successfully Product P001 synced")

      consumer.consume
    end

    it "logs consuming and processing, calls ProductSyncService, and logs success for destroy" do
      allow(consumer).to receive(:messages).and_return([ destroy_message ])

      service = instance_double(ProductSyncService)
      expect(Rails.logger).to receive(:info).with("Consuming messages from MyProductConsumer")
      expect(Rails.logger).to receive(:info).with(/Processing message:/)
      expect(ProductSyncService).to receive(:new).with(hash_including(destroy_data)).and_return(service)
      expect(service).to receive(:call)
      expect(Rails.logger).to receive(:info).with("Successfully Product 123 deleted")

      consumer.consume
    end

    it "logs error when ProductSyncService raises" do
      allow(consumer).to receive(:messages).and_return([ product_message ])

      expect(Rails.logger).to receive(:info).with("Consuming messages from MyProductConsumer")
      expect(Rails.logger).to receive(:info).with(/Processing message:/)
      expect(ProductSyncService).to receive(:new).and_raise(StandardError.new("fail"))
      expect(Rails.logger).to receive(:error).with(/Something Went Wrong: fail/)

      consumer.consume
    end

    it "logs error for unsupported payload type" do
      bad_message = double("Karafka::Message", payload: 123)
      allow(consumer).to receive(:messages).and_return([ bad_message ])

      expect(Rails.logger).to receive(:info).with("Consuming messages from MyProductConsumer")
      expect(Rails.logger).to receive(:info).with(/Processing message:/)
      expect(Rails.logger).to receive(:error).with(/Something Went Wrong: Unsupported payload type: Integer/)

      consumer.consume
    end
  end

  describe "#parse_message" do
    it "parses JSON string payload into symbolized hash" do
      json = { code: "P001", action: "create" }.to_json
      result = consumer.send(:parse_message, json)
      expect(result).to eq(code: "P001", action: "create")
    end

    it "symbolizes keys if payload is a hash" do
      hash = { "code" => "P002", "action" => "update" }
      result = consumer.send(:parse_message, hash)
      expect(result).to eq(code: "P002", action: "update")
    end

    it "raises error for unsupported payload type" do
      expect {
        consumer.send(:parse_message, 123)
      }.to raise_error(ArgumentError, /Unsupported payload type: Integer/)
    end
  end

  describe "#log_success" do
    it "logs synced message for create/update" do
      data = { code: "P003", action: "create" }
      expect(Rails.logger).to receive(:info).with("Successfully Product P003 synced")
      consumer.send(:log_success, data)
    end

    it "logs deleted message for destroy" do
      data = { id: "456", action: "destroy" }
      expect(Rails.logger).to receive(:info).with("Successfully Product 456 deleted")
      consumer.send(:log_success, data)
    end
  end
end
