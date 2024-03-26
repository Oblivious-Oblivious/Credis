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

  private def send_psync(master_socket)
    repl_id = "?";
    repl_offset = "-1";
    master_socket << encode_array ["psync", repl_id, repl_offset];
  end

  private def send_replconf_capa_psync2(master_socket)
    master_socket << encode_array ["replconf", "capa", "psync2"];
    master_socket.flush;
    if master_socket.gets == encode_simple_string("OK").chomp
      send_psync master_socket;
    end
  end

  private def send_replconf_port(master_socket)
    port = Redis::VALUES[:port];
    master_socket << encode_array ["replconf", "listening-port", port];
    master_socket.flush;
    if master_socket.gets == encode_simple_string("OK").chomp
      send_replconf_capa_psync2 master_socket;
    end
  end

  private def send_ping(master_socket)
    master_socket << encode_array ["ping"];
    master_socket.flush;
    if master_socket.gets == encode_simple_string("PONG").chomp
      send_replconf_port master_socket;
    end
  end

  private def connect_and_send_handshake_to_master
    host = Redis::VALUES[:master_host];
    port = Redis::VALUES[:master_port].to_i;
    master_socket = RedisSocket.new host, port;
    send_ping master_socket;
    master_socket.close;
  end

  def initialize(host, port)
    super host, port;

    if Redis::VALUES[:host_type] == "slave";
      connect_and_send_handshake_to_master;
    end
  end

  def start
    handle_clients;
  end
end
