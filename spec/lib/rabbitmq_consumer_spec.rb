require 'rails_helper'

require 'rabbitmq_consumer'

describe RabbitmqConsumer do

  describe "setting up the queue and bindings" do
    let(:options) {{
      :queue => "a_queue",
    }}
    let(:mock_session) { instance_double("Bunny::Session", :create_channel => mock_channel) }
    let(:mock_channel) { instance_double("Bunny::Channel", :queue => mock_queue, :prefetch => nil) }
    let(:mock_queue) { instance_double("Bunny::Queue") }
    let(:consumer) { RabbitmqConsumer.new(mock_session, lambda {}, options) }

    it "should create a channel and set the prefetch to 1" do
      expect(mock_session).to receive(:create_channel).and_return(mock_channel)
      expect(mock_channel).to receive(:prefetch).with(1)

      consumer.send(:queue)
    end

    it "should define the queue" do
      expect(mock_channel).to receive(:queue).with("a_queue", :durable => true).and_return(mock_queue)

      expect(consumer.send(:queue)).to eq(mock_queue)
    end

    it "should bind the queue to the exchange with the given routing key" do
      options[:bindings] = {"an_exchange" => "foo.bar"}
      mock_exchange = instance_double("Bunny::Exchange")
      expect(mock_channel).to receive(:topic).with("an_exchange", :passive => true).and_return(mock_exchange)
      expect(mock_queue).to receive(:bind).with(mock_exchange, :routing_key => "foo.bar")

      consumer.send(:queue)
    end

    it "should bind the queue to all given exchanges" do
      options[:bindings] = {
        "exchange1" => "foo.bar",
        "exchange2" => "bar.baz",
      }
      exchange1 = instance_double("Bunny::Exchange")
      exchange2 = instance_double("Bunny::Exchange")
      expect(mock_channel).to receive(:topic).with("exchange1", :passive => true).and_return(exchange1)
      expect(mock_queue).to receive(:bind).with(exchange1, :routing_key => "foo.bar")
      expect(mock_channel).to receive(:topic).with("exchange2", :passive => true).and_return(exchange2)
      expect(mock_queue).to receive(:bind).with(exchange2, :routing_key => "bar.baz")

      consumer.send(:queue)
    end
  end

  describe "subscription loop" do
    let(:options) {{ :queue => "a_queue" }}
    let(:mock_session) { instance_double("Bunny::Session", :create_channel => mock_channel) }
    let(:mock_channel) { instance_double("Bunny::Channel", :queue => mock_queue, :prefetch => nil) }
    let(:mock_queue) { instance_double("Bunny::Queue") }
    let(:consumer) { RabbitmqConsumer.new(mock_session, lambda {}, options) }

    it "should subscribe to the queue with the correct options" do
      expect(mock_queue).to receive(:subscribe).with(:manual_ack => true, :block => true)

      consumer.run
    end

    it "should call the processor with a RabbitmqConsumer::Message for each received message" do
      expect(mock_queue).to receive(:subscribe)
        .and_yield(:delivery_info1, :headers1, "message1_body")
        .and_yield(:delivery_info2, :headers2, "message2_body")

      messages = []
      consumer = RabbitmqConsumer.new(mock_session, lambda {|msg| messages << msg }, options)
      consumer.run

      expect(messages.size).to eq(2)
      expect(messages.map(&:delivery_info)).to eq([:delivery_info1, :delivery_info2])
      expect(messages.map(&:headers)).to eq([:headers1, :headers2])
      expect(messages.map(&:body)).to eq(["message1_body", "message2_body"])
    end
  end

  describe RabbitmqConsumer::Message do
    let(:mock_channel) { instance_double("Bunny::Channel") }
    let(:delivery_info) { instance_double("Bunny::DeliveryInfo", :channel => mock_channel, :delivery_tag => "a_tag") }
    let(:headers) { instance_double("Bunny::MessageProperties") }
    let(:body) { {"foo" => "bar"}.to_json }
    let(:message) { RabbitmqConsumer::Message.new(delivery_info, headers, body) }

    it "json decodes the body" do
      expect(message.body_data).to eq("foo" => "bar")
    end

    it "ack sends an ack to the channel" do
      expect(mock_channel).to receive(:ack).with("a_tag")
      message.ack
    end

    it "retry sends a reject to the channel with requeue set" do
      expect(mock_channel).to receive(:reject).with("a_tag", true)
      message.retry
    end

    it "reject sends a reject to the channel without requeue set" do
      expect(mock_channel).to receive(:reject).with("a_tag", false)
      message.discard
    end
  end
end
