class ProductKafkaProducerService
  TOPIC = "data_product".freeze

  def self.call(params)
    data = build_payload(params)

    Karafka.producer.produce_async(
      topic: TOPIC,
      payload: data
    )

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
