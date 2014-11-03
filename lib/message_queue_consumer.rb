class MessageQueueConsumer

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
