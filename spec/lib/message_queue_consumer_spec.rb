require 'rails_helper'

require 'message_queue_consumer'

describe MessageQueueConsumer do

  it ".run creates and runs a new instance with the config from rabbitmq.yml" do
    expected_config = YAML.load_file(Rails.root.join("config", "rabbitmq.yml"))[Rails.env]
    consumer = instance_double("MessageQueueConsumer")
    expect(MessageQueueConsumer).to receive(:new).with(expected_config).and_return(consumer)
    expect(consumer).to receive(:run)

    MessageQueueConsumer.run
  end

  describe "constructing an instance" do
    let(:config) {{
      "connection" => {
        "hosts" => ["rabbitmq1.example.com", "rabbitmq2.example.com"],
        "port" => 5672,
        "vhost" => "/",
        "user" => "a_user",
        "pass" => "super secret",
        "recover_from_connection_close" => true,
      },
      "queue" => "content_register",
      "exchange" => "published_documents",
    }}
    let(:rabbitmq_connecton) { instance_double("Bunny::Session", :start => nil) }
    before :each do
      allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
    end

    it "connects to rabbitmq" do
      expected_options = config["connection"].symbolize_keys # Bunny requires the keys to be symbols
      expect(Bunny).to receive(:new).with(expected_options).and_return(rabbitmq_connecton)
      expect(rabbitmq_connecton).to receive(:start)

      MessageQueueConsumer.new(config)
    end

    describe "constructing a RabbitmqConsumer" do
      it "passes the rabbitmq connection instance" do
        expect(RabbitmqConsumer).to receive(:new).with(rabbitmq_connecton, anything, anything)
        MessageQueueConsumer.new(config)
      end

      it "passes an instance of MessageQueueConsumer::Processor" do
        expect(RabbitmqConsumer).to receive(:new).with(anything, an_instance_of(MessageQueueConsumer::Processor), anything)
        MessageQueueConsumer.new(config)
      end

      it "passes the queue and binding details" do
        expected_details = {
          :queue => "content_register",
          :bindings => { "published_documents" => "#" },
        }
        expect(RabbitmqConsumer).to receive(:new).with(anything, anything, expected_details)
        MessageQueueConsumer.new(config)
      end
    end
  end
end
