# spec/services/product_sync_service_spec.rb
require "rails_helper"

RSpec.describe ProductSyncService do
  let(:valid_data) do
    {
      id: 1,
      code: "P001",
      name: "Sample Product",
      price: 10.0,
      stock: 100,
      description: "Sample description",
      action: "create"
    }
  end

  describe "#call" do
    context "when action is create/update" do
      it "creates a new product if it does not exist" do
        service = described_class.new(valid_data)
        expect { service.call }.to change(Product, :count).by(1)

        product = Product.find_by(code: "P001")
        expect(product.name).to eq("Sample Product")
        expect(product.price).to eq(10.0)
      end

      it "updates existing product if it exists" do
        product = Product.create!(
          id: 1,
          code: "P001",
          name: "Old Name",
          price: 5.0,
          stock: 50,
          description: "Old description"
        )

        service = described_class.new(valid_data.merge(name: "Updated Name", price: 20.0))
        service.call

        product.reload
        expect(product.name).to eq("Updated Name")
        expect(product.price).to eq(20.0)
      end

      it "logs success message" do
        service = described_class.new(valid_data)
        expect(Rails.logger).to receive(:info).with(/Data:/)
        expect(Rails.logger).to receive(:info).with(/Product Sync Successful:/)
        service.call
      end
    end

    context "when action is destroy" do
      it "destroys the product if it exists" do
        product = Product.create!(
          id: 1,
          code: "P001",
          name: "To be deleted",
          price: 10.0,
          stock: 100,
          description: "Sample description"
        )

        service = described_class.new(valid_data.merge(action: "destroy"))
        expect { service.call }.to change(Product, :count).by(-1)
      end

      it "does nothing if product does not exist" do
        service = described_class.new(valid_data.merge(action: "destroy", id: 999))
        expect { service.call }.not_to change(Product, :count)
      end

      it "logs success message for destroy" do
        product = Product.create!(valid_data.except(:action))
        service = described_class.new(valid_data.merge(action: "destroy"))
        expect(Rails.logger).to receive(:info).with(/Data:/)
        expect(Rails.logger).to receive(:info).with(/Product Sync Successful:/)
        service.call
      end
    end

    context "when an exception occurs" do
      it "rescues and logs error without raising" do
        service = described_class.new(valid_data)
        allow_any_instance_of(Product).to receive(:save!).and_raise(StandardError, "boom")

        expect(Rails.logger).to receive(:error).with(/Something Went Wrong: boom/)
        expect { service.call }.not_to raise_error
      end
    end
  end
end
