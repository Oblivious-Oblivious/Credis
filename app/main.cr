require "socket";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

class Object
  def safe!
    begin
      self.not_nil!;
    rescue NilAssertionError
      exit;
    end
  end
end

class TCPServer
  def accept!
    begin
      self.accept?.not_nil!;
    rescue NilAssertionError
      exit;
    end
  end
end

class Commands
  getter :client;

  def initialize(@client : TCPSocket) end

  def ping
    client << "+PONG\r\n";
  end
end

class YourRedisServer
  def start
    server = TCPServer.new "0.0.0.0", 6379;
    client = server.accept!;
    cmd = Commands.new client;

    cmd.ping;
  end
end

YourRedisServer.new.start;
