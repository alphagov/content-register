module MessageQueueHelpers

  def put_message_on_queue(message_data)
    # no-op for now
  end

  class << self
    def included(base)
      base.extend(ExampleGroupMethods)
    end
  end

  module ExampleGroupMethods
    def start_message_consumer_around_all
      before :each do
        # start consumer
      end

      after :each do
        # stop consumer
      end
    end
  end
end

RSpec.configuration.include(MessageQueueHelpers, :message_queue)
