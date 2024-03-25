require "socket";
require "./RedisProtocolParser";

class RedisServer < TCPServer
  include RedisProtocolEncoder;

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

  private def connect_and_send_handshake_to_master
    if Redis::ARGS[:host_type] == "slave"
      host = Redis::ARGS[:master_host];
      port = Redis::ARGS[:master_port];
      master_socket = RedisSocket.new host, port;
      master_socket << encode_array ["ping"];
      master_socket.close;
    end
  end

  def initialize(host, port)
    super host, port;
    connect_and_send_handshake_to_master;
  end

  def start
    handle_clients;
  end
end
