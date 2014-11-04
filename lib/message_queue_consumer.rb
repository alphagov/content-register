require 'rabbitmq_consumer'

class MessageQueueConsumer

  def self.run
    config = YAML.load_file(Rails.root.join('config', 'rabbitmq.yml'))[Rails.env]

    new(config).run
  end

  def initialize(config)
    @config = config.with_indifferent_access
    connection = Bunny.new(@config[:connection].symbolize_keys)
    connection.start
    consumer_config = {
      :queue => @config.fetch(:queue),
      :bindings => {
        @config.fetch(:exchange) => "#",
      },
    }
    @rmq_consumer = RabbitmqConsumer.new(connection, Processor.new, consumer_config)
  end

  def run
    @rmq_consumer.run
  end

  class Processor

    def call(message)
      content_id = message.body_data["content_id"]
      if content_id.present?
        entry = Entry.find_or_initialize_by(:content_id => content_id)
        if message.body_data["format"] == "placeholder" && entry.format.present?
          entry.update_attributes!(message.body_data.slice("title", "base_path"))
        else
          entry.update_attributes!(message.body_data.slice("title", "format", "base_path"))
        end
      end
      message.ack
    end
  end
end
