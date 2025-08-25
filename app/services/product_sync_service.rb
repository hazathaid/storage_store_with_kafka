class ProductSyncService
  def initialize(data)
    @data = data.symbolize_keys
  end

  def call
    if @data[:action] == "destroy"
      product = find_product
      product.destroy if product&.persisted?
      log_success(product)
    else
      product = find_or_initialize_product
      update_product(product)
      log_success(product)
    end
  rescue StandardError => e
    Rails.logger.error("Something Went Wrong: #{e.message}")
  end

  def find_or_initialize_product
    Product.find_or_initialize_by(code: @data[:code])
  end

  def find_product
    Product.find(@data[:id])
  end

  def update_product(product)
    product.assign_attributes(@data.except(:action, :id))
    product.save!
  end

  def log_success(product)
    Rails.logger.info("Data: #{@data.inspect}")
    action = @data[:action]
    Rails.logger.info("Product Sync Successful: #{product.id}, Action: #{action}")
  end
end
