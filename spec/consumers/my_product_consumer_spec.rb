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

  let(:message) { double("Racecar::Message", value: product_data.to_json) }
  let(:destroy_message) { double("Racecar::Message", value: destroy_data.to_json) }

  describe "#process" do
    context "when action is create/update" do
      it "calls ProductSyncService with parsed data and logs success" do
        service = instance_double(ProductSyncService)
        expect(ProductSyncService).to receive(:new).with(hash_including(product_data)).and_return(service)
        expect(service).to receive(:call)
        expect(Rails.logger).to receive(:info).with("Successfully Product P001 synced")

        consumer.process(message)
      end
    end

    context "when action is destroy" do
      it "calls ProductSyncService and logs destroy success" do
        service = instance_double(ProductSyncService)
        expect(ProductSyncService).to receive(:new).with(hash_including(destroy_data)).and_return(service)
        expect(service).to receive(:call)
        expect(Rails.logger).to receive(:info).with("Successfully Product 123 deleted")

        consumer.process(destroy_message)
      end
    end

    context "when an error occurs" do
      it "logs the error" do
        allow(ProductSyncService).to receive(:new).and_raise(StandardError.new("fail"))
        expect(Rails.logger).to receive(:error).with(/Something Went Wrong: fail/)

        consumer.process(message)
      end
    end
  end
end
