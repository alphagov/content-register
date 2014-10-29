
class MessageQueueConsumer
  class Message
    # @param delivery_info [Bunny::DeliveryInfo]
    # @param headers [Bunny::MessageProperties]
    # @param payload [String]
    def initialize(delivery_info, headers, payload)
      @delivery_info = delivery_info
      @headers = headers
      @body = payload
    end

    attr_reader :delivery_info, :headers, :body

    def json_body
      @json_body ||= JSON.parse(@body)
    end

    def ack
      @delivery_info.channel.ack(@delivery_info.delivery_tag)
    end

    def retry
      @delivery_info.channel.reject(@delivery_info.delivery_tag, true)
    end

    def discard
      @delivery_info.channel.reject(@delivery_info.delivery_tag, false)
    end
  end

  # @param config [Hash{Symbol => String}] The http status code
  # @param processor [#call] For each message received from the queue, this
  #   will be called with a corresponding instance of Message
  def initialize(config, processor)

    @exchange_name = config.fetch(:exchange)
    @queue_name = config.fetch(:queue)

    @processor = processor

    @connection = Bunny.new(config.except(:exchange, :queue))
    @connection.start
  end

  def run
    queue.subscribe(:block => true, :manual_ack => true) do |delivery_info, headers, payload|
      @processor.call(Message.new(delivery_info, headers, payload))
    end
  rescue Timeout::Error, Bunny::Exception # TODO: review exceptions to rescue
    reset_channel
    # Notify Errbit
    retry
  end

  private

  def queue
    @queue ||= setup_queue
  end

  def setup_queue
    @channel = @connection.create_channel
    @channel.prefetch(1) # only one unacked message at a time
    exchange = @channel.topic(@exchange_name, :passive => true)
    queue = @channel.queue(@queue_name, :durable => true)
    queue.bind(exchange, :routing_key => '#')
    queue
  end

  def reset_channel
    @queue = nil
    @channel.close if @channel and @channel.open?
    @channel = nil
  end
end
