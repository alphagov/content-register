class MessageProcessor

  def call(message)
    puts <<-EOT
----- New Message -----
Routing_key: #{message.delivery_info.routing_key}
Properties: #{message.headers.inspect}
Payload: #{message.body}
    EOT

    message.ack
  end
end
