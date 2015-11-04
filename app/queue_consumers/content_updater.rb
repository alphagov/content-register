# ContentUpdater
#
# Receives messages from RabbitMQ and updates the register.
class ContentUpdater
  def process(message)
    content_id = message.payload["content_id"]

    # Ignore non-english items until a more nuanced approach can be created.
    if content_id.present? && message.payload["locale"] == "en"
      entry = Entry.find_or_initialize_by(:content_id => content_id)
      if message.payload["format"] == "placeholder" && entry.format.present?
        entry.update_attributes!(message.payload.slice("title", "base_path"))
      elsif message.payload["format"] =~ /\Aplaceholder_(.*)\z/
        entry.update_attributes!(message.payload.slice("title", "base_path").merge(:format => $1))
      else
        entry.update_attributes!(message.payload.slice("title", "format", "base_path", "links"))
      end
    end

    message.ack
  rescue ActiveRecord::RecordNotUnique
    message.retry
  end
end
