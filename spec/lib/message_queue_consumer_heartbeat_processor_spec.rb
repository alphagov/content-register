require 'rails_helper'

require 'message_queue_consumer'

describe MessageQueueConsumer::HeartbeatMiddlewareProcessor do
  let(:heartbeat_headers) { instance_double("Bunny::MessageProperties", :content_type => "application/x-heartbeat") }
  let(:heartbeat_message) { instance_double("RabbitmqConsumer::Message", :headers => heartbeat_headers, :ack => nil) }
  let(:standard_headers) { instance_double("Bunny::MessageProperties", :content_type => nil) }
  let(:standard_message) { instance_double("RabbitmqConsumer::Message", :headers => standard_headers, :ack => nil) }

  let(:processor) { instance_double("MessageQueueConsumer::Processor") }

  subject {
    MessageQueueConsumer::HeartbeatMiddlewareProcessor.new(processor)
  }

  context "for a heartbeat message" do
    it "doesn't call the next processor" do
      expect(processor).not_to receive(:call)

      subject.call(heartbeat_message)
    end

    it "acks the message" do
      expect(heartbeat_message).to receive(:ack)

      subject.call(heartbeat_message)
    end
  end

  context "for a content message" do
    it "calls the next processor" do
      expect(processor).to receive(:call).with(standard_message)

      subject.call(standard_message)
    end

    it "doesn't ack the message" do
      expect(standard_message).not_to receive(:ack)
      expect(processor).to receive(:call)

      subject.call(standard_message)
    end
  end
end
