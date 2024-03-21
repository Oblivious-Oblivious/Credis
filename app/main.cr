require "socket";
require "./extensions/TCPServer+accept!";
require "./Commands";

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit; };

class YourRedisServer
  def start
    server = TCPServer.new "0.0.0.0", 6379;
    client = server.accept!;
    cmd = Commands.new client;

    while message = client.gets
      if message == "ping"
        cmd.ping;
      end
    end
  end
end

YourRedisServer.new.start;
