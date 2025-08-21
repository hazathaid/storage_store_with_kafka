class MyProductConsumer < Racecar::Consumer
  subscribes_to "storage-product"

  def process(message)
    data = parse_message(message.value)

    ProductSyncService.new(data).call
    log_success(data)
  rescue StandardError => e
    Rails.logger.error("Something Went Wrong: #{e.message}")
  end

  private

  def parse_message(value)
    JSON.parse(value, symbolize_names: true)
  end

  def log_success(data)
    if data[:action] == "destroy"
      Rails.logger.info "Successfully Product #{data[:id]} deleted"
    else
      Rails.logger.info "Successfully Product #{data[:code]} synced"
    end
  end
end
