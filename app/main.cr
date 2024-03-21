require "socket";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

class Commands
  getter :client;

  def initialize(@client : TCPSocket) end

end

class YourRedisServer
  private def setup_client
    server = TCPServer.new "0.0.0.0", 6379;
    client = server.accept?;
  end

  private def generate_commands_from(client : TCPSocket | Nil)
    begin
      client = client.not_nil!;
      cmd = Commands.new client;
    rescue NilAssertionError
      exit;
    end
  end

  def start
    server = TCPServer.new "0.0.0.0", 6379;
    client = server.accept?;
    cmd = generate_commands_from client;

  end
end

YourRedisServer.new.start;
