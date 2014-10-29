
namespace :message_queue do

  desc "Consume messages from the published_documents queue"
  task :consumer => :environment do
    require 'message_processor'
    require 'message_queue_consumer'

    config = YAML.load_file(Rails.root.join('config', 'rabbitmq.yml'))[Rails.env].symbolize_keys
    processor = MessageProcessor.new
    MessageQueueConsumer.new(config, processor).run
  end
end
