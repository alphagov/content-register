
namespace :message_queue do

  desc "Run worker to consume messages from rabbitmq"
  task :consumer => :environment do
    while true
      sleep 10
    end
  end
end
