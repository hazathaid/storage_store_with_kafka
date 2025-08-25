# frozen_string_literal: true

class MyProductConsumer < Karafka::BaseConsumer
  def consume
    Rails.logger.info "Consuming messages from #{self.class.name}"
    messages.each do |message|
      begin
        Rails.logger.info "Processing message: #{message.payload}"
        data = parse_message(message.payload)

        ProductSyncService.new(data).call
        log_success(data)
      rescue StandardError => e
        Rails.logger.error("Something Went Wrong: #{e.message}")
      end
    end
  end

  private

  def parse_message(value)
    case value
    when String
      JSON.parse(value, symbolize_names: true)
    when Hash
      value.symbolize_keys
    else
      raise ArgumentError, "Unsupported payload type: #{value.class}"
    end
  end

  def log_success(data)
    if data[:action] == "destroy"
      Rails.logger.info "Successfully Product #{data[:id]} deleted"
    else
      Rails.logger.info "Successfully Product #{data[:code]} synced"
    end
  end
end
