class MyProductConsumer < Racecar::Consumer
  subscribes_to "storage-product"

  def process(parameter)
    data = JSON.parse(parameter.value, symbolize_names: true)
    product = Product.find_or_initialize_by(code: data[:code])
    product.update(name: data[:name], description: data[:description], price: data[:price], stock: data[:stock])
    Rails.logger.info "Success Saved Product #{product.code}"
  rescue => e
    Rails.logger.error("Something When Wrong #{e.message}")
  end
end
