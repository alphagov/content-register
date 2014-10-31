require 'childprocess'

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
      process = nil

      before :all do
        puts "Starting message consumer"
        ChildProcess.posix_spawn = true
        process = ChildProcess.build("ruby", "-S", "bundle", "exec", "rake", "message_queue:consumer")
        process.leader = true
        process.start
      end

      after :all do
        if process && process.alive?
          puts "Stopping message consumer"
          process.stop
        end
      end
    end
  end
end

RSpec.configuration.include(MessageQueueHelpers, :message_queue)
