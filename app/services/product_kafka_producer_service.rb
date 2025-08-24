class ProductKafkaProducerService
  KAFKA_BROKERS = [ "localhost:9092" ].freeze
  CLIENT_ID = "storage_rails".freeze
  TOPIC = "storage-product".freeze

  def self.call(params)
    kafka = Kafka.new(KAFKA_BROKERS, client_id: CLIENT_ID)
    data = build_payload(params)
    kafka.deliver_message(data, topic: TOPIC)
    data
  end

  def self.build_payload(params)
    params = params.transform_keys(&:to_s)
    {
      "id"          => params["id"],
      "code"        => params["code"],
      "name"        => params["name"],
      "stock"       => params["stock"],
      "price"       => params["price"],
      "description" => params["description"],
      "action"      => params["action"]
    }.to_json
  end
end
