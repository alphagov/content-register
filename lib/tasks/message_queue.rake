namespace :message_queue do
  desc "Run worker to consume messages from RabbitMQ"
  task :consumer => [:environment] do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "content_register",
      exchange: "published_documents",
      processor: ContentUpdater.new
    ).run
  end
end
