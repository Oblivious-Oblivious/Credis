class RedisServer < TCPServer
  private def handle_request(redis_client)
    while message = redis_client.gets
      redis_client.send message;
    end
  end

  private def handle_clients
    while redis_client = self.accept
      spawn do
        handle_request redis_client;
      end
    end
  end

  def start
    handle_clients;
  end
end
