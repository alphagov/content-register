
namespace :message_queue do

  desc "Run worker to consume messages from rabbitmq"
  task :consumer => :environment do
    require 'message_queue_consumer'
    MessageQueueConsumer.run
  end
end
