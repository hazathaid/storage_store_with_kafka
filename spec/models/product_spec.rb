require 'rails_helper'

RSpec.describe Product, type: :model do
  it "is valid with valid attributes" do
    product = Product.new(
      code: "P001",
      name: "Product 1",
      price: 10.0,
      stock: 100,
      description: "Description for Product 1"
    )
    expect(product).to be_valid
  end

  it "is not valid without a code" do
    product = Product.new(code: nil)
    expect(product).to_not be_valid
  end

  it "is not valid without a name" do
    product = Product.new(name: nil)
    expect(product).to_not be_valid
  end

  it "is not valid with a negative price" do
    product = Product.new(price: -1)
    expect(product).to_not be_valid
  end

  it "is not valid with a negative stock" do
    product = Product.new(stock: -1)
    expect(product).to_not be_valid
  end

  it "is not valid with a description longer than 500 characters" do
    product = Product.new(description: "a" * 501)
    expect(product).to_not be_valid
  end
end
