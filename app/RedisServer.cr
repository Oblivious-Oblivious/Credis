require "socket";
require "./RedisProtocolParser";

class RedisServer < TCPServer
  private def handle_request(redis_client)
    cmd_builder = "";
    while data = redis_client.gets
      cmd_builder += data + "\r\n";
      cmds = RedisProtocolParser.new(cmd_builder).decode_stream;
      if cmds != [[""]]
        redis_client.send cmd_builder, cmds;
        cmd_builder = "";
      end
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
